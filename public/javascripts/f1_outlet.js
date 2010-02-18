// FortiusOne Outlet! v0.2a
// Outlet! is the set of tools that makes it easy for a developer to build a site on top of the GeoCommons API.
// Requires: f1_maker_map.js v0.2a and the Prototype JavaScript framework, version 1.6.0.1




// Fully customizable javascript pagination system. Initialize it with the id of a placeholder
// element to replace. Populate it with an array of html strings. Override the generated xhtml
// by passing in new templates.
var Paginations = {
  lookup: {},
  register: function(item) {
    Paginations.lookup[item.element.id] = item
  }
}
var Paginate = Class.create({
  initialize: function(element) {
    this.element = $(element)
    Paginations.register(this)
    this.options = Object.extend({
      start_page: 1,
      page_list: new Template('<ul>#{html}</ul><div id="page_control_#{id}" class="page_control"></div>'),
      page:      new Template('<li id="#{id}_page_#{number}" class="#{id}_page"#{hide}>#{html}</li>'),
      prev_off:  new Template('<span class="prev off">&laquo; Previous</span>'),
      prev_on:   new Template('<span class="prev #{page_show_classes}">&laquo; Previous</span>'),
      next_off:  new Template('<span class="next off">More &raquo;</span>'),
      next_on:   new Template('<span class="next #{page_show_classes}">More &raquo;</span>'),
      page_off:  new Template('<span class="page_dot off">&bull;</span>'),
      page_on:   new Template('<span class="page_dot #{page_show_classes}">&bull;</span>')
    }, arguments[1] || { });
  },
  populate: function(list) {
    var page_html = ""
    var i = 1
    list.each(function(p) {
      page_html += this.options.page.evaluate({ 
                       id: this.element.id, 
                       hide: (i!=this.options.start_page ? "style='display:none'" : ""),
                       number: i, 
                       html: p })
      i++
    }.bind(this))
    this.total = i-1
    this.element.update( this.options.page_list.evaluate({
        id: this.element.id,
        html:page_html }))
    this.pages = $$('.' + this.element.id + '_page')
    this.page_control = $("page_control_" + this.element.id)
    this.show_class = 'show_' + this.element.id + '_page'
    this.update_page_control( this.options.start_page )    
  },
  
  class_pair: function(number) {
    return(this.show_class + ' ' + this.show_class + "_" + number)
  },
  update_page_control: function(current) {
    if(this.total <= 1) {return ""}
    var html = ""
    if(current == 1) { 
      html += this.options.prev_off.evaluate({}) 
    } else {
      html += this.options.prev_on.evaluate({page_show_classes: this.class_pair(current-1)}) 
    }
    for(var i=1; i <= this.total; i++) {
      if(current==i) { 
        html += this.options.page_off.evaluate({}) 
      } else {
        html += this.options.page_on.evaluate({page_show_classes: this.class_pair(i)})
      }
    }
    if(current == this.total) { 
      html += this.options.next_off.evaluate({}) 
    } else {
      html += this.options.next_on.evaluate({page_show_classes:this.class_pair(current+1)}) 
    }
    this.page_control.update(html)
    $$('#' + this.page_control.id + ' .' + this.show_class).invoke(
          'observe', 'click', this.pick.bind(this) )
  },
  pick: function(ev) {
    ev.stop();
    var el = ev.element()
    var number = parseInt(id_from_class_pair(el, this.show_class))
    this.show(number)
  },
  show: function(number) {
    var page = $(this.element.id + "_page_" + number)
    this.pages.without(page).invoke('hide')
    page.show()
    this.update_page_control(parseInt(number))
  }
})

var PaginatedMapLists = {
  lookup: {},
  register: function(item) {
    PaginatedMapLists.lookup[item.element.id] = item
  }
}
var PaginatedMapList = Class.create({
  initialize: function(element, jsonData) {
    this.element = $(element);
    PaginatedMapLists.register(this)
    this.options = Object.extend({
      per_page: 5,
      map_list_options: {}
    }, arguments[2] || { });
    this.populate(jsonData)
  },
  populate: function(jsonData) {
    var slices      = jsonData.eachSlice(this.options.per_page)
    var total_pages = slices.length
    var p           = new Paginate(this.element)
    p.populate(slices.map(function(){return "Loading..."}))
    for(i=0;i<total_pages;i++) {
      var list = new MapList(this.element.id + "_page_" + (i+1), [], this.options.map_list_options)
      list.populate(slices[i])
    }
  }
})


// Display a list of maps from Maker.find_maps jsonData output.
// Options: 
//    title_format: 'full' will display a list with titles and descriptions
//    title_format: 'short' will display a list only with titles
//    title_format: [template string] allows you to specify your own title template.
//                  ex: MapList.on_list_maps(jsonData, {title_format: "<h1>#{title}</h1>" })
var MapLists = {
  lookup: {},
  register: function(item) {
    MapLists.lookup[item.element.id] = item
  }
}
var MapList = Class.create({
  initialize: function(element) {
    this.element = $(element);
    MapLists.register(this)
    this.map_list_id = this.element.id.replace(/map_list_([^_]+?)_.*/,'$1')
    this.options = Object.extend({
      title_format: 'short',
      list_format: '<ul>#{items}</ul>',
      item_format: '<li id="maplist_item_#{pk}">\
                      <a href="javascript:void(0)" class="load_map load_map_#{pk}">#{title}</a>\
                      <div class="overlays_panel_button">\
                    </li>',
      after_item_click: function(el,id) {}
    }, arguments[2] || { });
  },
  populate: function(jsonData) {
    var title
    if (this.options.title_format == 'full') {
      title = new Template('<strong>#{title}</strong><br/>#{description}') 
    } else if (this.options.title_format == 'short') {
      title = new Template('#{title}') 
    } else if (this.options.title_format == 'reveal') {
      title = new Template('<strong>#{title}</strong><br/><span class="desc">#{description}</span>')
    } else if ( /\#\{title\}/.test(this.options.title_format) ) {
      title = new Template(this.options.title_format)
    }
    var item =  new Template(this.options.item_format);
    var items = ""
    var thisMapList = this
    jsonData.each(function(e){
          items += item.evaluate({  title: title.evaluate({title:e.name, description:e.description}), 
                                    description: e.description, 
                                    pk: e.pk,
                                    maker_url: Maker.maker_host})  
        })
    this.element.update( new Template(this.options.list_format).evaluate({items:items}) )
    this.observe_list()
  },
  populate_map_overlays: function(map, overlays, template) {
    var result = ""
    overlays.each(function(o) { result += template.evaluate(o) })
    return result
  },
  observe_list: function() {
    $$('#' +this.element.id+ ' .load_map').invoke('observe','click', this.on_item_click.bind(this) )
  },
	reobserve_gracefully: function(unique_function_id) {
		var self = this;

		var function_id;
		if (unique_function_id == null)
		{
			function_id = (new Date()).getTime();
		} else {
			function_id = unique_function_id;
		}
		News.callbacks = {};
		News.callbacks[function_id] = function() { setTimeout(function() {self.observe_list()}, 500); };

		callback = "News.callbacks[" + function_id + "]";
		console.log(callback);
		if ($(FlashMap.dom_id).setCallback != null)
		{
			$(FlashMap.dom_id).setCallback("MapLoad", callback);
		} else {
			setTimeout(self.reobserve_gracefully(function_id), 100);
		}
	},
  on_item_click: function(ev) {
    ev.stop();
    var el = ev.element()
    while (el.tagName != 'A') {el = $(el.parentNode)}
		$$('#' +this.element.id+ ' .load_map').invoke('stopObserving');
    this.select_item(el)
    var id = id_from_class_pair(el, "load_map")
    this.set_url_hash(id)
    FlashMap.load_map('maker_map', id)
    this.options.after_item_click(el,id)
		this.reobserve_gracefully();
  },
  on_toggle_overlays: function(ev) {
    ev.stop();
    var el = ev.element()
    while (el.tagName != 'A') {el = $(el.parentNode)}
    // get parent a
    var id = id_from_class_pair(el, "show_overlays")
    $('overlays_' + id).toggle()
    $('show_overlays_' + id).toggle()
    $('hide_overlays_' + id).toggle()
  },
  set_url_hash: function(id){
    var match = this.element.id.match(/map_list_([0-9]+)_page_([0-9]+)/)
    UrlHash.set('/'+match[1]+'/' +match[2]+ '/'+id)  // == /list_id/page_id/map_id
  },
  
  select_item: function(el) {
    el = $(el)
    var id = id_from_class_pair(el, "load_map")
    $$('.load_map.on').invoke('toggleClassName','on')
    el.toggleClassName('on')
  }
})

var UrlHash = {
  set: function(new_location) {
    window.location = "#" + new_location;
  },
  get: function() {
    return window.location.hash.split('#')[1]
  }
}


var Accordion = {
  initialize: function(ev) {
    $$('.expand').invoke('observe','click', Accordion.pick)
    Accordion.panels = $$('.panel')
  },
  pick: function(ev) {
    ev.stop();
    var el = ev.element()
    var panel = $("panel_" + id_from_class_pair(el, "expand"))
    Accordion.expand(panel)
  },
  expand: function(panel) {
    panel = $(panel)
    if (panel) {
      Accordion.panels.without(panel).each(function(panel){
        Accordion.transition(panel, 'minimize')
      })
      Accordion.transition(panel, 'maximize')
    }
  },
  transition: function(panel,action) {
    var lng  = $$('#'+panel.id +' .long' ).first()
    var shrt = $$('#'+panel.id +' .short').first()
    if (action=='maximize' && !lng.visible()) {
      if(Prototype.Browser.IE) { 
        shrt.hide(); lng.show();
      } else {
        Accordion.tween_swap(shrt, lng)
      }
    } 
    if (action=='minimize') {
      if (lng) {
        if(Prototype.Browser.IE || 1==1) {
          lng.hide(); shrt.show();
        } else {
          Accordion.tween_swap(lng, shrt)
        }
      } else {
        shrt.show()
      }
    }
  },
  
  tween_swap: function(from,to) {
    to.style.overflow = 'hidden'
    to.style.visibility = 'hidden'  //visibility hack required in order to get an accurate height calculation on a 'display:none' object.
    to.show()
    var heightStart = from.getHeight()
    var heightEnd = to.getHeight()
    to.style.height = heightStart + 'px'
    to.style.visibility = 'visible'
    from.hide() 
    new Effect.Tween(to, heightStart, heightEnd, {duration: 0.5}, function(v){this.style.height = v + 'px'});
  } 
}



// Retrieves the id from a class name pair such as: "open_overlay open_overlay_23"
// So, id_from_class_pair(el,"open") will return "overlay_23"
// or, id_from_class_pair(el,"open_overlay") will return "23"
function id_from_class_pair(el, action) {
  var r = new RegExp(".*"+action+"_([^ ]+).*")
  return el.className.replace(r,'$1')
}

