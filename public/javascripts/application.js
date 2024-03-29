r_info = []
markerList = []
infoBubbleList = []

window.onhashchange = function (){trace_hash()}

$(document).ready(function() {
	android_size()

	$("html").live('tap', function(event){
		close_web_popup()
	})	
	
	$(".description .overflow").live('tap', function(event){
		event.stopPropagation();
	})	
	
	$(".review .description").live('tap', function(event){
		event.stopPropagation();
		var id = $(this).attr('id').slice(1)
		ajax_get_restaurant('restaurants/show/' + id)
	})
	
	$(window).scroll(function() {
		
		var scroll_top = $(window).scrollTop();
		
		if ($("#search_map_canvas_big").hasClass('hidden')) {
			if (scroll_top <= 10) { $('.application').css({ 'top':'60px' }) }
		} else {
			if (scroll_top <= 275) { $('.application').css({ 'top': 335 - scroll_top + 'px' }) }
		}
		
  })
	
	$(".source_type, .src_photo_link").live('tap', function(event){
		event.stopPropagation();
		loader('Redirecting to source website')
	})
	
	$(".close_popup").live('tap', function(event){
		$(this).parent().addClass('hidden')
		$(".b_share").removeClass('pressed')
		$.cookie("ask_version", 1);
		return false
	})
	
	$(".review").live('tap', function(event){
		element = $(this)
		$(".review").not(this).children('.description').removeClass('show')
		
		$(".review").not(this).removeClass('slide_2')
		$(".review").not(this).removeClass('slide_3')
		
		if (($(".review").index(element) - 1)%3 == 0) {
			element.toggleClass('slide_2')
		} else if (($(".review").index(element) - 2)%3 == 0) {
			element.toggleClass('slide_3')
		}

		$(this).children('.description').toggleClass('show')
	})
	
	$("#submit_location").live('tap', function(event){
		href = "http://maps.google.com/maps/api/geocode/json?address=" + encodeURI($(this).prev('input').val()) + "&sensor=true"
		$.ajax({
		    url: href,
		    type: 'GET',
				dataType: 'html',
		    success: function(data) {
				
				obj = $.parseJSON($($(data.responseText)[5]).text())
				
				if (obj.results[0] != null){
					lat = obj.results[0].geometry.location.lat
					lng = obj.results[0].geometry.location.lng
					$.cookie("lat", lat);
					$.cookie("lng", lng);
				} else {
					$.cookie("lat", "40.7143528");
					$.cookie("lng", "-74.00597309999999");
				}
				
				$("#ask_location").removeClass('show')
				
				$.ajax({
			        url: '/restaurants/index',
			        type: 'get',
			        dataType: 'script',
			        success: function() {
			          loading = false;
								init_scroll()
			        }
			    })
			
		    }
		})
		return false
	})
	
	$(".b_share").live('tap', function(event){
		$(this).toggleClass('pressed')
		$("#share").toggleClass('hidden')
		
	})
	
	$("#share #fb").live('tap', function(event){
		button = $(this)		
		button.toggleClass('pressed')
		$("#fb_share_text").toggleClass('show')
		$("#fb_share_button").toggleClass('show')
		return false
	})
	
	$("#share #tw").live('tap', function(event){
		button = $(this)		
		button.toggleClass('pressed')
		$("#tw_share_text").toggleClass('show')
		$("#tw_share_button").toggleClass('show')
		return false
	})
	
	$("#fb_share_button, #tw_share_button").live('tap', function(event){
		var obj = $(this)
		var ldr_text = $(this).attr('id') == 'fb_share_button' ? 'Sending to Facebook' : 'Sending to Twitter'
		loader(ldr_text)	

		$.ajax({
	        url: obj.prev().prev().attr('href') + "&text=" + obj.prev().val(),
	        type: 'get',
	        dataType: 'json',
	        success: function() {
						loader()
						loader('Shared successfully!')
						setTimeout(function(){
							obj.removeClass('show')
							obj.prev().removeClass('show')
							obj.prev().prev().removeClass('pressed')
							obj.parent().addClass('hidden')
							$(".b_share").removeClass('pressed')
							loader()
						},1000)
	        }
	  })
		return false
	})
	
	$("#user_img_profile").live('tap', function(event){
		ajax_get_user_profile()
	})
	
	$("#bbutton").live('tap', function(event){
		event.preventDefault();
		$(this).addClass('pressed')
		ajax_get_restaurants(back_url)
	})
	
	$("#search_restaurant, #web_search").live('tap', function(event){
		close_web_popup()
		$('#search_map_field').toggleClass('hidden')
		$(this).toggleClass('pressed')
		return false
	})
	
	$("#search_me").live('tap', function(event){
		loader('Searching')
		keyword = $(this).prev('input').val()

		center = map.getCenter()
		$.cookie("search", keyword);
		$.cookie("lat", center.lat());
		$.cookie("lng", center.lng());		
		
		$.ajax({
        url: 'restaurants?search=' + keyword + '&lng=' + center.lng() + '&lat=' + center.lat(),
        type: 'get',
        dataType: 'script',
        success: function() {
					if (keyword != '') {
						$('#search_map_field').removeClass('hidden')
						$('#search_field').val(keyword);
					}
					refresh_scroll()
					size_map()
					setTimeout(function(){ loader() },10);
        }
    })
	})
	
	$("#search_on_map, #stlw").live('tap', function(event){
		close_web_popup()
		loader('Loading places next to You')
		center = map.getCenter()
		
		$(this).addClass('pressed')
		$.cookie("lat", center.lat());
		$.cookie("lng", center.lng());
		$.cookie("search", '');
		
		$.ajax({
        url: 'restaurants?lng=' + center.lng() + '&lat=' + center.lat(),
        type: 'get',
        dataType: 'script',
        success: function() {
					refresh_scroll()
					size_map()
					setTimeout(function(){ loader() },10);
        }
    })

	})
	
	$(".restaurant_name").live('tap', function(event){
		close_web_popup()
		$(this).parent().parent().parent().addClass('tapped')
		window.location.hash = $(this).attr('href');
		return false
	})
	
	if ($("#splashscreen").length > 0){
		
		document.ontouchmove = function(e) {e.preventDefault()}				
		navigator.geolocation.getCurrentPosition(getLocation, unknownLocation);
	
		id = setInterval(function(){
			
			if ($.cookie("clear_interval")!= null){
				clearInterval(id);
				$.cookie("clear_interval", null);
			}
			
			if ($.cookie("lat") != null && $.cookie("lng") != null){
				clearInterval(id);
				trace_hash()
			}
		},200);
	}
	
	$(".map_link").live('tap', function(event){
		event.preventDefault();
	})
	
	$(".close_map").live('tap', function(event){
		
		$('#search_map_canvas').removeClass('expand_search_map_canvas')
		$(this).addClass('pressed')
		
		setTimeout(function(){ $(".close_map").addClass('hidden').removeClass('pressed') },50);
		
		$('#search_on_map').addClass('hidden')
		$("#user_img_profile").removeClass('hidden')
		
		$.cookie("map", 'small');
		return false
	})
	
	if ($("#map_canvas").length > 0){
		map = load_map('map_canvas')
		id = $('.flag_content:first').attr('id')	
		setMarkers(map, [[r_info[id]['name'], r_info[id]['lat'], r_info[id]['lng'], 1, r_info[id]['rating'], r_info[i]['type'] ]])
	}
	
	$('.restaurant name').live('tap', function(event){
		event.preventDefault();
		event.stopPropagation();
	})
	
	$('#search_map_canvas').live('tap', function(event){

		$(this).addClass('expand_search_map_canvas')
		$('.close_map').removeClass('hidden')

		$('#user_img_profile').addClass('hidden')
		$.cookie("map", 'big');

		setTimeout(
			function(){
				$('#search_on_map').removeClass('hidden')
		}, 400);
		
		event.preventDefault();
		event.stopPropagation();
		refresh_scroll()
		
	})
	
	// Restauants button
	$('#resataurants_button').live('tap', function(){
		navigator.geolocation.getCurrentPosition(getLocation, unknownLocation);
		setInterval(function(){
			if ($.cookie("lat") != null && $.cookie("lng") != null){
				window.location.href = '/restaurants'
			}
		},200);
		return false;
	})
	
	// Restaurant Dish Info slide	
	$('.dish_info_container .rating').live('swipeleft', function(event){
		
		el = $(this).parent()
		if (!(el.parent().hasClass('expand') && !el.hasClass('slideLeft'))) {
			el.parent().toggleClass('expand')
			console.log(el)
		}		
		el.toggleClass('slideLeft')

		container.next('.comment').addClass('hidden')
		container.nextAll('.src_photo_link').addClass('hidden')
		
		setTimeout(function () {refresh_scroll()}, 300);
	})
	
	$('.dish_info_container').live('swiperight', function(event){
		$(this).parent().removeClass('expand')
		$(this).removeClass('slideLeft')
		
		$(this).next('.comment').removeClass('hidden')
		$(this).nextAll('.src_photo_link').addClass('hidden')
		
		setTimeout(function () {refresh_scroll()}, 300);
	})
	
	$('.dish_info_container').live('tap', function(event){
		
		dish = $(this).parent()
		container = $(this)
		
		console.log(dish.hasClass('expand'))
		console.log(container.hasClass('slideLeft'))
		
		if (dish.hasClass('expand') && container.hasClass('slideLeft')){
			container.next('.comment').removeClass('hidden')
			container.nextAll('.src_photo_link').addClass('hidden')
		} else {
			container.next('.comment').addClass('hidden')
			container.nextAll('.src_photo_link').addClass('hidden')
		}
		
		if (!(dish.hasClass('expand') && !container.hasClass('slideLeft'))){
			$(this).parent().toggleClass('expand')
		}
		
		$(this).toggleClass('slideLeft')
		 setTimeout(function () {refresh_scroll()}, 300);
	})
	
	$('.dish_info_container').live('tap', function(event){
		event.stopPropagation();
	})
	
	// Restaurant info dish expand
	$('.dish').live('tap', function(){
		dish = $(this)
		$('.dish').not(this).removeClass('expand')
		$(this).toggleClass('expand')
		setTimeout(function () {
			
			if (dish.hasClass('expand')) {
				dish.children('.comment').addClass('hidden')
				dish.children('.src_photo_link').removeClass('hidden')
			} else {
				dish.children('.comment').removeClass('hidden')
				dish.children('.src_photo_link').addClass('hidden')
			}
			
			refresh_scroll()}, 300);

	})
	
	$('.flag_content').live('swipeleft', function(){
		
		$('.dish_info').removeClass('swipe')
		$(this).closest('.dish_info').addClass('swipe')		
		current_div = $(this)
		
		setTimeout(
			function(){
				id = current_div.attr('id')	
				setMarkers(map, [[r_info[id]['name'], r_info[id]['lat'], r_info[id]['lng'], 1, r_info[id]['rating'], r_info[i]['type']]])
				$('#map_canvas').appendTo(current_div.closest('.dish_info').find('.map_canvas')).show()
		}, 350);
		
	})
	

	$('.stats').live('tap', function(){
		num_agree = $(this).next('.users').find('.num').text().replace(/\D/g, '')
		num_disagree = $(this).children('.disagree').text().replace(/\D/g, '')

		$(this).children('.disagree').text('#' + num_agree +  ' user(s) agree')
		$(this).next('.users').find('.num').text('+' + num_disagree)
		
		$(this).next('.users').toggleClass('like').toggleClass('dislike')
		
		stat = $(this).children('.opinion').text().indexOf('Awesome') != -1 ? 'Awful' : 'Awesome'
		$(this).children('.opinion').text('It`s ' + stat)
		
		$(this).prev('.user_photo').find('.photo').toggleClass('slide_down')
		$(this).next().find('.profile').toggleClass('hidden')
		
		$(this).children('.name').toggleClass('opacity_zero')
		$(this).children('.name_disagree').toggleClass('opacity_zero')
		
		event.stopPropagation()
		event.preventDefault()
	})
	
	$('.review .dish_info').live('swiperight', function(){
		$(this).removeClass('swipe')
	})
	
	// Users count slide
	$('.users').live('swipeleft', function(){
		$(this).addClass('slide')
		$(this).prev('.stats').addClass('opacity_zero')
		event.preventDefault()
		event.stopPropagation()
	})
	
	$('.users').live('swiperight', function(){
		$(this).removeClass('slide')
		$(this).prev('.stats').removeClass('opacity_zero')
		event.preventDefault()
		event.stopPropagation()
	})
	
	// Awesome && Awfull Buttons
	$('.btn_agree_aw, .btn_disagree_aw').live('tap', function(){
		event.stopPropagation()
		
		elem = $(this)
		href = elem.attr('href')		
		stats = elem.parent('.btn_container').prevAll('.stats')
		rating = elem.parent('.btn_container').parent('.dish_info').prev('.rating')
		
		$.getJSON(href, function(json) {
			if (json.url) {
				$("#login_popup").removeClass('hidden')
				// loader('Connecting to Facebook')
				// window.location.href = json.url
			} else {
				
				elem.addClass('tapped')
				if (elem.attr('class').indexOf('btn_agree_aw') != -1) {
					
					elem.prevAll('.status_aw').addClass('set_agree_aw')
					stats.find('.like').text(json.likes)
					stats.find('.dislike').text(json.dislikes)
					rating.html('<span>You <span class="like_it">like it</span></span>')
					
				} else {
					
					elem.prevAll('.status_aw').addClass('set_disagree_aw')
					stats.find('.dislike').text(json.dislikes)
					stats.find('.like').text(json.likes	)
					rating.addClass('dislike').html('<span>You <span class="hate_it">hate it</span></span>')
					
				}
				setTimeout(function(){elem.removeClass('tapped')}, 100)

			}
		 });
		return false
	})
	
	$('.status_aw').live('tap', function(event){
		event.stopPropagation()
		
		elem = $(this)
		href = elem.attr('href')
		
		stats = elem.parent('.btn_container').prevAll('.stats')
		rating = elem.parent('.btn_container').parent('.dish_info').prev('.rating')
		
		rating.removeClass('dislike')
		elem.addClass('opacity_zero')
		
		$.getJSON(href, function(json) {
			elem.addClass('tapped')
						
			stats.find('.dislike').text(json.dislikes)
			stats.find('.like').text(json.likes)
			rating.text(json.likes)
			
			setTimeout(function(){
				elem.removeClass('set_agree_aw').removeClass('opacity_zero').removeClass('tapped');
				elem.removeClass('set_disagree_aw').removeClass('opacity_zero').removeClass('tapped');
			}, 100)
		})
		return false
	})

});

function trace_hash() {
	if (window.location.hash == '') {
		ajax_get_restaurants('/restaurants?back=1')					
	} else if (window.location.hash.indexOf('restaurants') != -1) {
		ajax_get_restaurant(window.location.hash.slice(1))
	}	else if (window.location.hash.indexOf('profile') != -1) {
		ajax_get_user_profile()
	}
}

function ajax_get_restaurants(link) {

	loader('Loading places next to You')
	$('html, body').animate({scrollTop:0}, 'slow');
	
	$.ajax({
      url: link,
      type: 'get',
      dataType: 'script',
      success: function() {
				init_scroll()				
				center = map.getCenter()
				size_map()
				
				if ($.cookie("search") != null) {
					if ($.cookie("search").length > 0) {
						$('#search_map_field').removeClass('hidden')
						$('#search_field').val($.cookie("search"))
					}
				}							
				setTimeout(function(){ loader() },10);
      }
  })
}

function ajax_get_restaurant(href) {
	
	loader('Analyzing millions of reviews')
	$('html, body').animate({scrollTop:0}, 'slow');
	
	$.ajax({
      url: href,
      type: 'get',
      dataType: 'script',
      success: function() {
				
				$('#search_restaurant').addClass('hidden')
				$(".close_map").addClass('hidden');
				$("#bbutton").attr('href', '/').removeClass('hidden');
				$('#search_map_canvas_big').addClass('hidden')
				$('#stlw').addClass('hidden')
				
				init_scroll()
				
				setTimeout(function(){ loader() },10);
      }
  })
}

function ajax_get_user_profile() {
	$('html, body').animate({scrollTop:0}, 'slow');
	loader('Loading your data')
	$.ajax({
      url: '/users/profile',
      type: 'get',
      dataType: 'script',
      success: function() {
				window.location.hash = 'profile';
				$('#search_map_canvas_big').addClass('hidden')
				$('#stlw').addClass('hidden')
				setTimeout(function(){ loader() },100);
				init_scroll()
      }
  })
}


function close_web_popup() {
	$("#web_popup").addClass('hidden')
	$.cookie("ask_version", 1);
}

function check_Android() {
	return (navigator.userAgent.indexOf("Android") != -1) ? 1 : 0
}

function check_iPhone() {
	return (navigator.userAgent.indexOf("iPhone") != -1) ? 1 : 0
}

function check_iPad() {
	return (navigator.userAgent.indexOf("iPad") != -1) ? 1 : 0
}

function check_mobile() {
	return (check_Android() == 1 || check_iPhone() == 1 || check_iPad() == 1) ? 1 : 0
}

function refresh_scroll() {
	if (check_mobile() == 1) {
		myScroll.refresh()
	}
	android_size()
}

function init_scroll() {
	document.ontouchmove = function(e) {e.preventDefault()}
	$('.description').children('.overflow').each(function(index, item){
		if ($(item).height() >= 175) {
			item.ontouchmove = function(e) {e.stopPropagation()}
		}
	})
	if (typeof myScroll != 'undefined'){
		myScroll.destroy();
		myScroll = null;
	}
	
	if (check_mobile() == 1) {
		myScroll = new iScroll('wrapper', { 
			scrollbarClass: 'myScrollbar',
			onBeforeScrollStart: function() {}
		})
	} else {
		$("#wrapper").css("position", "relative");
	}
	android_size()

}

function android_size(){
	if (navigator.userAgent.indexOf("Android") != -1) {
		$("#container").addClass('android')
		$("#search_map_canvas").addClass('android')
		$(".dish").addClass('android')
	}
}

function loader(message) {
	message ? $('#loader').text(message).removeClass('hidden') : $('#loader').addClass('hidden')
}

function preload(images) {	
	$(images).each(function(index){

		var bgImg = new Image()		
		var el = $($("div.dish")[index])
		
		bgImg.onload = function(){
			el.css('background-image', 'url(' + bgImg.src + ')');
			el.prev('.preloader').addClass('hidden')
		};
		
		if (this == '') {el.prev('.preloader').addClass('hidden')}
		bgImg.src = this;
	});
}

function size_map() {
	if ($.cookie("map") == 'big') {
		$('#user_img_profile').addClass('hidden')
		$(".close_map").removeClass('hidden')
		$('#search_map_canvas').addClass('expand_search_map_canvas')
		setTimeout(
			function(){
				$('#search_on_map').removeClass('hidden')
		}, 400);
	}
}

function getLocation(pos)
{
	$.cookie("lat", pos.coords.latitude);
	$.cookie("lng", pos.coords.longitude);
}

function unknownLocation(interval_id)
{
	if ($.cookie("lat") == null || $.cookie("lng") == null){
	  $('#ask_location').addClass('show')
		$.cookie("clear_interval", 1)
	}
}

function load_map(element_id) {
  var mapOptions = {
		mapTypeControl: false,
		streetViewControl: false,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		maxZoom: 15,
		center: new google.maps.LatLng(0,0)
  }
  map = new google.maps.Map(document.getElementById(element_id),mapOptions);
	return map
	// setMarkers(map, markers);
}

//Clear all markers
function clearMarkers() {
	for (var i=0; i< markerList.length; i++) {
		markerList[i].setMap(null);		
	}
}

// Add markers to the map
function setMarkers(map, locations) {
	if (typeof markerList != 'undefined') {
		clearMarkers()
	}
  // Add markers to the map
  // Marker sizes are expressed as a Size of X,Y
  // where the origin of the image (0,0) is located
  // in the top left of the image.

  // Origins, anchor positions and coordinates of the marker
  // increase in the X direction to the right and in
  // the Y direction down.
  var image = new google.maps.MarkerImage('/images/point_trsp.gif',
      // This marker is 20 pixels wide by 32 pixels tall.
      new google.maps.Size(32, 40),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 0,32.
      new google.maps.Point(16, 32));
  // var shadow = new google.maps.MarkerImage('http://code.google.com/intl/ru-RU/apis/maps/documentation/javascript/examples/images/placeflag_shadow.png',
      // The shadow image is larger in the horizontal dimension
      // while the position and offset are the same as for the main image.
      // new google.maps.Size(37, 32),
      // new google.maps.Point(0,0),
      // new google.maps.Point(0, 32));
      // Shapes define the clickable region of the icon.
      // The type defines an HTML <area> element 'poly' which
      // traces out a polygon as a series of X,Y points. The final
      // coordinate closes the poly by connecting to the first
      // coordinate.
  var shape = {
      coord: [1, 1, 1, 26, 21, 26, 21, 1],
      type: 'poly'
  };
	var bounds = new google.maps.LatLngBounds();
	
	var infowindow = new google.maps.InfoWindow();

	var marker, i, b;
	
  for (var i = 0; i < locations.length; i++) {
    var place = locations[i];
    var myLatLng = new google.maps.LatLng(place[1], place[2]);
	
    var marker = new google.maps.Marker({
        position: myLatLng,
        map: map,
        icon: image,
        shape: shape,
        title: place[0],
        zIndex: place[3]
    });

		var label = new Label({
			map: map
		    });
		    label.set('zIndex', 1);
		    label.bindTo('position', marker, 'position');
		    label.set('text', i + 1);
		
			
		google.maps.event.addListener(marker, 'click', (function(marker, i) {
	    return function() {

				if (typeof infoBubble != 'undefined') {
					infoBubble.close();
				}

        infoBubble = new InfoBubble({
          map: map,
          content: '<a onClick="ajax_get_restaurant(this.href);return false" class="map_link" href="/restaurants/show/'+locations[i][4]+'">'+locations[i][0]+' '+locations[i][5]+' '+locations[i][6]+'</a>',
          position: new google.maps.LatLng(parseFloat(locations[i][1]) + 0.0000, locations[i][2] - 0.0002),
          shadowStyle: 1,
          padding: 5,
          backgroundColor: '#8DC63F',
          borderRadius: 4,
          arrowSize: 0,
          borderWidth: 1,
          borderColor: '#ccc',
          disableAutoPan: true,
          hideCloseButton: true,
          // arrowPosition: 30,
          // backgroundClassName: '',
          // arrowStyle: 1
        });
				infoBubble.open();
				
				google.maps.event.addListener(map, "click", function(){
				  infoBubble.close();
				});
	    }
	  })(marker, i));
	
		markerList.push(marker);
		bounds.extend(myLatLng);
  }
	map.fitBounds(bounds);
	map_center = bounds.getCenter();
	map_center.Ya = map_center.Ya + 0.0009
	map_center.Xa = map_center.Xa + 0.0022
	map.setCenter(map_center);	
	
}

// Define the overlay, derived from google.maps.OverlayView
function Label(opt_options) {
     // Initialization
     this.setValues(opt_options);
 
     // Here go the label styles
     var span = this.span_ = document.createElement('span');
     span.style.cssText = 'position: relative; left: -14px; top: -34px;' +
                          'padding: 7px 0px 0px 7px;' +
													'background-image: url(/images/pointer.png);' +
													'background-size: 100%;' +
													'display: block;' +
													'width: 34px;' +
													'height: 27px;' +
                          'font-size: 14px;';
 
     var div = this.div_ = document.createElement('div');
     div.appendChild(span);
     div.style.cssText = 'position: absolute; display: none';
};
 
Label.prototype = new google.maps.OverlayView;
 
Label.prototype.onAdd = function() {
     var pane = this.getPanes().overlayImage;
     pane.appendChild(this.div_);
 
     // Ensures the label is redrawn if the text or position is changed.
     var me = this;
     this.listeners_ = [
          google.maps.event.addListener(this, 'position_changed',
               function() { me.draw(); }),
          google.maps.event.addListener(this, 'text_changed',
               function() { me.draw(); }),
          google.maps.event.addListener(this, 'zindex_changed',
               function() { me.draw(); })
     ];
};
 
// Implement onRemove
Label.prototype.onRemove = function() {
     this.div_.parentNode.removeChild(this.div_);
 
     // Label is removed from the map, stop updating its position/text.
     for (var i = 0, I = this.listeners_.length; i < I; ++i) {
          google.maps.event.removeListener(this.listeners_[i]);
     }
};
 
// Implement draw
Label.prototype.draw = function() {
     var projection = this.getProjection();
     var position = projection.fromLatLngToDivPixel(this.get('position'));
     var div = this.div_;
     div.style.left = position.x + 'px';
     div.style.top = position.y + 'px';
     div.style.display = 'block';
     div.style.zIndex = this.get('zIndex'); //ALLOW LABEL TO OVERLAY MARKER
     this.span_.innerHTML = this.get('text').toString();
};