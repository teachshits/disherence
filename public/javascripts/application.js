r_info = []
markerList = []
infoBubbleList = []

$(document).ready(function() {
	
	$(".review").live('tap', function(event){
		element = $(this)
		
		if (($(".review").index(element) - 1)%3 == 0) {
			console.log(2)
		} else if (($(".review").index(element) - 2)%3 == 0) {
			console.log(3)
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
						myScroll = new iScroll('wrapper', { 
							scrollbarClass: 'myScrollbar'
						})
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
	
	$("#share #fb, #share #tw").live('tap', function(event){
		button = $(this)		
		button.toggleClass('pressed')
		setTimeout(function(){
			button.parent().addClass('hidden')
			loader('Sending to Facebook')	
		},1000)
		
		$.ajax({
        url: button.attr('href'),
        type: 'get',
        dataType: 'json',
        success: function() {
					loader(loader('Shared successfully!'))	
					setTimeout(function(){ loader() },1000)
        }
    })
		return false
	})
	
	$("#user_img_profile").live('tap', function(event){
		loader('Loading your data')
		$.ajax({
        url: 'users/profile',
        type: 'get',
        dataType: 'script',
        success: function() {	
					setTimeout(function(){ loader() },0);
					myScroll.destroy();
					myScroll = null;
					myScroll = new iScroll('wrapper', { 
						scrollbarClass: 'myScrollbar'
					})
        }
    })

	})
	
	$("#bbutton").live('tap', function(event){
		loader('Loading places next to You')
		event.preventDefault();
		center = map.getCenter()
		
		$(this).addClass('pressed')
		
		$.ajax({
        url: back_url,
        type: 'get',
        dataType: 'script',
        success: function() {

					myScroll.destroy();
					myScroll = null;
					myScroll = new iScroll('wrapper', { 
						scrollbarClass: 'myScrollbar'
					})		
					
					if ($.cookie("search") != null) {
						$('#search_map_field').removeClass('hidden')
						$('#search_field').val($.cookie("search"))
					}
					size_map()
        }
    })
	})
	
	$("#search_restaurant").live('tap', function(event){
		$('#search_map_field').toggleClass('hidden')
		$(this).toggleClass('pressed')
	})
	
	$("#search_me").live('tap', function(event){
		loader('Loading places next to You')
		keyword = $(this).prev('input').val()

		center = map.getCenter()
		$.cookie("search", keyword);
		$.cookie("lat", center.Xa);
		$.cookie("lng", center.Ya);		
		
		
		$.ajax({
        url: 'restaurants?search=' + keyword + '&lng=' + center.Ya + '&lat=' + center.Xa,
        type: 'get',
        dataType: 'script',
        success: function() {
					if (keyword != '') {
						$('#search_map_field').removeClass('hidden')
						$('#search_field').val(keyword);
					}
					myScroll.refresh();	
					size_map()
					setTimeout(function(){ loader() },10);
        }
    })

	})
	
	$("#search_on_map").live('tap', function(event){
		
		loader('Loading places next to You')
		center = map.getCenter()
		
		$(this).addClass('pressed')
		$.cookie("lat", center.Xa);
		$.cookie("lng", center.Ya);
		$.cookie("search", '');
		
		$.ajax({
        url: 'restaurants?lng=' + center.Ya + '&lat=' + center.Xa,
        type: 'get',
        dataType: 'script',
        success: function() {
					myScroll.refresh();
					size_map()
					setTimeout(function(){ loader() },10);
        }
    })

	})
	
	$(".restaurant_name").live('tap', function(event){
		loader('Analyzing millions of reviews')
		event.preventDefault();
		ajax_get_restaurant($(this).attr('href'))
		setTimeout(function(){ loader() },10);
	})
	
	if ($("#splashscreen").length > 0){

		document.ontouchmove = function(e) {e.preventDefault()}				
		navigator.geolocation.getCurrentPosition(getLocation, unknownLocation);

		var loading = true		
		setInterval(function(){
			if ($.cookie("lat") != null && $.cookie("lng") != null && loading == true){
				$.ajax({
		        url: '/restaurants/index',
		        type: 'get',
		        dataType: 'script',
		        success: function() {
		          loading = false;
							myScroll = new iScroll('wrapper', { 
								scrollbarClass: 'myScrollbar'
							})
		        }
		    })
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
		myScroll.refresh();
		
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
	$('.dish_info_container .rating').live('swipeleft tap', function(event){
		$(this).parent().parent().addClass('expand')
		$(this).parent().addClass('slideLeft')
		setTimeout(function () {myScroll.refresh();}, 300);
	})
	
	$('.dish_info_container').live('swiperight', function(event){
		$(this).parent().removeClass('expand')
		$(this).removeClass('slideLeft')
		setTimeout(function () {myScroll.refresh();}, 300);
	})
	
	$('.dish_info_container').live('tap', function(event){
		event.stopPropagation();
	})
	
	// Restaurant info dish expand
	$('.dish').live('tap', function(){
		$('.dish').not(this).removeClass('expand')
		$(this).toggleClass('expand')
		setTimeout(function () {myScroll.refresh();}, 300);

	})
	
	// Restaurant info data
	$(".place_name, .restaurant .name").live('tap', function(){
		loader('Analyzing millions of reviews')
		event.preventDefault()
		href = $(this).attr('href')		
		$.ajax({
	        url: href,
	        type: 'get',
	        dataType: 'script',
	        success: function() {
					setTimeout(function () {
							myScroll = new iScroll('wrapper', { 
								scrollbarClass: 'myScrollbar', 
								onBeforeScrollStart: function() {} 
							})
							loader()
						}, 0);
	        }
	    })
	})
	
	if ($("#wrapper").length > 0){
		document.ontouchmove = function(e) {e.preventDefault()}
		$('.users').children('.profiles').each(function(index, item){ item.ontouchmove = function(e) {e.stopPropagation()} })
		
		var flag = true
		var page = 1
		v_height = document.getElementById('wrapper').scrollHeight

		myScroll = new iScroll('wrapper', { 
			scrollbarClass: 'myScrollbar', 
			onBeforeScrollStart: function() {} ,
		})		
	}
	
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
		
		$.getJSON(href, function(json) {
			if (json.url) {
				loader('Connecting to Facebook')
				window.location.href = json.url
			} else {
				
				elem.addClass('tapped')
				if (elem.attr('class').indexOf('btn_agree_aw') != -1) {
					
					elem.prevAll('.status_aw').addClass('set_agree_aw')
					stats.find('.like').text(json.likes)
					stats.find('.dislike').text(json.dislikes)
					
				} else {
					
					elem.prevAll('.status_aw').addClass('set_disagree_aw')
					stats.find('.dislike').text(json.dislikes)
					stats.find('.like').text(json.likes	)
					
				}

			}
		 });
		return false
	})
	
	$('.status_aw').live('tap', function(event){
		event.stopPropagation()
		
		elem = $(this)
		href = elem.attr('href')
		stats = elem.parent('.btn_container').prevAll('.stats')
		
		elem.addClass('opacity_zero')
		
		$.getJSON(href, function(json) {
			
			stats.find('.dislike').text(json.dislikes)
			stats.find('.like').text(json.likes	)
			
			setTimeout(function(){
				elem.removeClass('set_agree_aw').removeClass('opacity_zero');
				elem.removeClass('set_disagree_aw').removeClass('opacity_zero');
			}, 400)
		})
		return false
	})

});


function loader(message) {
	$('#loader').toggleClass('hidden')
	if (message) {
		$('#loader').text(message)
	}
}

function preload(arrayOfImages) {
    $(arrayOfImages).each(function(){
        $('<img/>')[0].src = this;
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

function ajax_get_restaurant(href) {
	loader()
	$.ajax({
      url: href,
      type: 'get',
      dataType: 'script',
      success: function() {
				$('#search_restaurant').addClass('hidden')
				$(".close_map").addClass('hidden');
				$("#bbutton").attr('href', '/').removeClass('hidden');
				myScroll = new iScroll('wrapper', { 
					scrollbarClass: 'myScrollbar',
					onBeforeScrollMove: function ( e ) {
						if ($(".description").length > 0){
							e.preventDefault();
						}
					}
				})
				setTimeout(function(){ loader() },10);
      }
  })
}


function getLocation(pos)
{
	$.cookie("lat", pos.coords.latitude);
	$.cookie("lng", pos.coords.longitude);
}

function unknownLocation()
{
	if ($.cookie("lat") == null || $.cookie("lng") == null){
	  $('#ask_location').addClass('show')
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