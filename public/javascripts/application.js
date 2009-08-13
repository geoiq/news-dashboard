// All of the code related to the view of this Outlet application here.
var News = {
  default_map_list: "",
  default_map_list_page: "",
  default_map: "",
  
  create_panels: function(element, jsonData) {
    jsonData.each(function(data) {
      News.create_panel(element,data);
    })
  },
  
  create_panel: function(element, jsonData) {
    element = $(element)
    var maplist = jsonData.map_list
    var panel = new Template('<div id="panel_#{id}" class="panel"> \
                                <label><a href="#" class="expand expand_#{id}">#{title}</a></label> \
                                <div class="short">#{short}</div>  \
                                <div class="long" style="display:none"> \
                                  <div class="map_list" id="map_list_#{id}">#{long}</div> \
                                </div> \
                              </div>')
    element.insert(panel.evaluate({
      id: maplist.id,
      title: maplist.title,
      short: maplist.description,
      long: 'Loading...' }))
    News.load_map_list(maplist)
  },
  
  //eval requried because jsonp responses from Maker don't include anything but data
  //so there's no way to specify in the reponse which request we are responding to -mc 2009-02-11
  load_map_list: function(maplist) {
    News.determine_default_map(maplist)
    var callback = "panel_" + maplist.id + "_results"
    eval("News[callback] = function(jsonData){News.on_search_results(jsonData,'map_list_"+maplist.id+"','"+maplist.maps_sort_order+"')}")
    Maker.find_maps(maplist.maker_tag, maplist.maker_user, "News." + callback)
  },
  determine_default_map: function(maplist){
    if (News.default_map_list == "") {News.default_map_list = maplist.id}
    var url_hash = UrlHash.get()
    if(url_hash) {
      var ids = url_hash.match(/^\/([0-9]+)\/([0-9]+)\/([0-9]+)\/?$/)
      if(ids) {
        News.default_map_list = ids[1]
        News.default_map_list_page = ids[2]
        News.default_map = ids[3]
      }
    }
  },
  on_search_results: function(jsonData, element, maps_sort_order) {
    element = $(element)
    var results = News.prepare_data(jsonData, maps_sort_order)
    if(results.length == 0) {element.innerHTML = "No maps found for this topic."; return}
    var explore_list = new PaginatedMapList(element, results, {
                            title_format: "cool: #{title}",
                            per_page: 8 })
    if (News.default_map == "") {News.default_map = results[0].pk}
    if (News.default_map_list_page == "") {News.default_map_list_page = 1}
    News.load_default_map(element)
  },
  load_default_map: function(element){
    if( "map_list_" + News.default_map_list == element.id) {
      Accordion.expand('panel_' + News.default_map_list)
      Paginations.lookup[element.id].show(News.default_map_list_page);
      MapLists.lookup[element.id + '_page_' + News.default_map_list_page].select_item($$('.load_map_' + News.default_map)[0]);
      Maker.load_map('maker_map', News.default_map, {
        afterFinish : function(){
                            Maker.resize_when_ready()
                            Event.observe(window, 'resize', Maker.resize_map_to_fit) }  })
    }
  },
  
  prepare_data: function(jsonData, maps_sort_order){
    var jsonMapData = jsonData.reject(function(e){return e.type != "Map"})
    if (maps_sort_order) {
      return News.custom_sort(jsonMapData, maps_sort_order)
    } else {
      return jsonMapData.sortBy(function(s) {return s.indexed_tags})
    }
  },
  
  custom_sort: function(jsonMapData, maps_sort_order){
    var sorted = []
    maps_sort_order = maps_sort_order.split(',')
    jsonMapData.each(function(map) {
      sorted = jsonMapData.sortBy(function(map){
        var position = maps_sort_order.indexOf(map.pk.toString())
        if(position == -1) position = 9999
        return position
      })
    })
    return sorted
  },
  
  // for the sortable list of maps in admin. Puts the sort order into a hidden field
  // to submit with the rest of the form.
  load_sortable_map_list: function(maplist) {
    var callback = "panel_" + maplist.id + "_results"
    eval("News[callback] = function(jsonData){News.on_sortable_search_results(jsonData,'map_list_"+maplist.id+"',maplist)}")
    Maker.find_maps(maplist.maker_tag, maplist.maker_user, "News." + callback)
  },
  
  on_sortable_search_results: function(jsonData, element, map_list) {
    element = $(element)
    console.log(['map_list', map_list.default, map_list.default_map_id])
    results = News.prepare_data(jsonData, map_list.maps_sort_order)
    var id = id_from_class_pair(element, 'map_list')
    if(results.length == 0) {element.innerHTML = "No maps found for this topic."; return}
    var explore_list = new MapList(element, results, {
      list_format: "<ul id='sortable_list_"+ id +"' class='sortable_items'>#{items}</ul>",
      item_format: "<li id='sortable_item_#{pk}'>\
                      #{title}\
                      <span><a href='#' class='default_map' pk='#{pk}'>Default Map?</a></span>\
                    </li>"
    })
    explore_list.populate(results)
    $$('.sortable_items').each(function(list) {
      Sortable.create("sortable_list_" + id, {
        onUpdate: function(list) {
          var order = []
          Sortable.sequence(list).each(function(v){
            order.push(parseInt(v))
          })
          var id = list.id.replace('sortable_list_','')
          $('map_list_' +id+ '_maps_sort_order').value = order
        } 
      })
    })
    if(map_list.default) {
      $$('#sortable_item_' +map_list.default_map_id+ ' a').invoke('addClassName','on')
    }
    News.observe_default_buttons(element)
  },
  
  observe_default_buttons: function(map_list){
    $$('#' +map_list.id+ ' .default_map').invoke('observe','click', function(ev) {
      ev.stop(); var el = ev.element();
      $(map_list.id+ '_default_map_id').value = el.getAttribute('pk')
      $$('.default_map.on').invoke('removeClassName','on')
      $$('.default_toggle').each(function(el) {el.value = 'f'})
      $(map_list.id+ "_default").value = 't';
      el.toggleClassName('on')
    })
  }
}

var KeySync = {
  initialize: function(ev) {
    $$('.keysync').invoke('observe','change', KeySync.sync)
  },
  sync: function(ev) {
    var el = ev.element()
    var target = $(id_from_class_pair(el, "keysync"))
    target.innerHTML = el.value
  }
}

var SortableMapList = {
  initialize: function() {
    Sortable.create('sortable_map_list', {
      onUpdate: SortableMapList.update
    })
  },
  update: function(list) {
    Sortable.sequence(list).each(function(v,i){
      $("map_list_"+v+"_sort_order").value = i
    })
  }
}

function id_from_class_pair(el, action) {
  var r = new RegExp(".*"+action+"_([^ ]+).*")
  return el.className.replace(r,'$1')
}