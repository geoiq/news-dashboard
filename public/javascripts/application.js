// All of the code related to the view of this Outlet application here.
var News = {
  default_map_list: "",
  default_map_list_page: "",
  default_map: "",
  maps: {},
  panel_count: 0,
  panels_loaded: 0,
  
  create_panels: function(element, jsonData) {
    News.panel_count = jsonData.length
    jsonData.each(function(data) {
      News.create_panel(element,data);
    })
    News.init_caption_observers()
    News.init_embed_template()
    News.init_intro_observers()
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
    News.panels_loaded++
    element = $(element)
    var results = News.prepare_data(jsonData, maps_sort_order)
    if(results.length == 0) {element.innerHTML = "No maps found for this topic."; return}
    News.index_maps(results)
    var per_page = News.smart_per_page(results)
    var explore_list = new PaginatedMapList(element, results, {
                            per_page: per_page,
                            map_list_options: {
                              title_format: "#{title}",
                              after_item_click: News.after_item_click
                            }})
    if (News.default_map == "") {News.default_map = results[0].pk}
    if (News.default_map_list_page == "") {News.default_map_list_page = 1}
    if ("map_list_" + News.default_map_list == element.id) {News.default_map_list = element.id}
    if (News.panels_loaded == News.panel_count) {
      $('loading_maps').hide()
      $('continue_button').show()  // Display the 'continue' link 
      News.load_default_map()
    }
  },
  smart_per_page: function(results){
    // This is broken - i.title does not exist; maybe mean "name"?
    //var avg = results.inject(0, function(acc, i) { return acc + i.name.length; }) / results.length
    avg = 100
    if(avg < 20) {return 8}
    if(avg < 40) {return 6}
    if(avg < 60) {return 4}
    return 4
  },
  after_item_click: function(el,id){
    $('embed').hide()
    News.current_map = id
    News.show_caption_for_map(id)
    Maker.resize_when_ready() // FIXME: this doesn't seem to fire for heavier maps
  },
  
  show_caption_for_map: function(id){
    News.update_caption(id)
    $('caption').show()
    $('caption').setStyle({width: (document.viewport.getWidth() - 400) + 'px'})
    $('map_title').update(News.maps[id].title)
    $('view_in_maker').href = Maker.maker_host + '/maps/' + id
    $('view_in_kml').href = Maker.maker_host + '/maps/' + id + '.kml'
  },
  
  update_caption: function(id){
    var l,r,c,desc,sen
    desc = News.maps[id].description ? News.maps[id].description : ""
    sen = desc.split('. ')
    $('short_description').update( sen.slice(0,1).join('. '))
    sen.length == 1 ? $('more_caption').hide() : $('more_caption').show()
    var words = desc.split(' ')
    if(words.length > 50) {
      c = Math.floor(words.length/2)
      l = words.slice(0,c).join(' ')
      r = words.slice(c).join(' ')
    } else {
      l = words.join(' ')
      r = ''
    }
    $('long_description_l').update(l)
    $('long_description_r').update(r)
    var overlay_template = new Template("&nbsp;&nbsp;&nbsp;&nbsp;<img src='/images/b.finder.png'/>&nbsp;&nbsp;<a class='overlay_link' href='#{url}'>#{name}</a><br/>")
    overlays = News.maps[id].overlays
    var overlay_list = ""
    overlays.each(function(o) { overlay_list += overlay_template.evaluate(o) } )
    $('overlays_list').update( overlay_list )
  },
  init_caption_observers: function() {
    $$('.toggle_caption').invoke('observe','click', function(ev){
      ev.stop()
      $('short_description').toggle()
      $('more_caption').toggle()
      $('long_description').toggle()
    })
    $('hide_caption').observe('click', function(ev){
      ev.stop()
      $('show_caption').clonePosition('hide_caption')
      var cap = $$('#caption .caption')[0]
      cap.morph('left: -' +cap.getDimensions().width+ 'px', {duration: 0.5, afterFinish:function(){cap.hide()}})
      $('show_caption').show()
    })
    $('show_caption').observe('click',function(ev) {
      ev.stop()
      $$('#caption .caption')[0].show()
      $$('#caption .caption')[0].morph('left:1px', {duration: 0.5})
      $('show_caption').hide()
    })
    $$('.toggle_layers').invoke('observe', 'click', function(ev){
      ev.stop()
      $('overlays').toggle()
      $('show_layers').toggle()
      $('hide_layers').toggle()
    })
    $('reveal_share').observe('click', function(ev) {
      ev.stop()
      News.update_embed()
      $('embed').show()
      var d = $('embed').getDimensions()
      $('embed').clonePosition('reveal_share',{
        setWidth:false, setHeight:false, offsetTop:-(parseInt(d.height)+30), offsetLeft:-(parseInt(d.width)-89)
      })
    })
    $('dismiss_share').observe('click', function(ev) {
      ev.stop()
      $('embed').hide()
    })
  },
  
  init_embed_template: function() {
    News.embed_template = $('embed_code').value //keep a copy of the original embed template
  },
  update_embed: function() {
    $('embed_code').value = News.embed_template.replace(/%mapid%/g,News.current_map)
  },
  
  init_intro_observers: function(){
    $('continue_button').observe('click', function(){
      $('atlas_panels').show()
      News.update_panels()
      $('panel_welcome').hide()
      $('continue_button').hide()
    })
  },
  
  // Makes the panels display the map_list, page and map stored in the defaults. Needs refactoring.
  update_panels: function() {
    Accordion.expand('panel_' + News.default_map_list.replace('map_list_',''))
    Paginations.lookup[News.default_map_list].show(News.default_map_list_page);
    MapLists.lookup[News.default_map_list + '_page_' + News.default_map_list_page].select_item($$('.load_map_' + News.default_map)[0]);
  },
  
  load_default_map: function(element){
    Maker.load_map('maker_map', News.default_map, {
      afterFinish : function(){
                          Maker.resize_when_ready()
                          Event.observe(window, 'resize', Maker.resize_map_to_fit) }  })
    News.show_caption_for_map(News.default_map)
    News.current_map = News.default_map
  },
  
  prepare_data: function(jsonData, maps_sort_order){
    var jsonMapData = jsonData.reject(function(e){return e.type != "Map"})
    if (maps_sort_order) {
      return News.custom_sort(jsonMapData, maps_sort_order)
    } else {
      return jsonMapData.sortBy(function(s) {return s.indexed_tags})
    }
  },
  
  index_maps: function(results) {
    results.each(function(map) {
      News.maps[map.pk] = map
    })
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
  
  // ----- begin Admin Organize screen lists TODO: put this in a separate js file -----------
  // for the sortable list of maps in admin. Puts the sort order into a hidden field
  // to submit with the rest of the form.
  load_sortable_map_list: function(maplist) {
    var callback = "panel_" + maplist.id + "_results"
    eval("News[callback] = function(jsonData){News.on_sortable_search_results(jsonData,'map_list_"+maplist.id+"',maplist)}")
    Maker.find_maps(maplist.maker_tag, maplist.maker_user, "News." + callback)
  },
  on_sortable_search_results: function(jsonData, element, map_list) {
    element = $(element)
    results = News.prepare_data(jsonData, map_list.maps_sort_order)
    var id = id_from_class_pair(element, 'map_list')
    if(results.length == 0) {element.innerHTML = "No maps found for this topic."; return}
    var explore_list = new MapList(element, results, {
      list_format: "<ul id='sortable_list_"+ id +"' class='sortable_items'>#{items}</ul>",
      item_format: "<li id='sortable_item_#{pk}'>\
                      <p>#{title}</p>\
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
    if(map_list['default']) {
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
  // end Admin Organize screen lists -----------
  
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