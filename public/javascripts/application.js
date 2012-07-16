$(document).bind('pagecreate',function(){
	
	$('#resataurants_button').live('click', function(){
		
		link = $(this).attr('href');

		navigator.geolocation.getCurrentPosition(getLocation, unknownLocation);
		
		setInterval(function(){
			if ($.cookie("lat") != null && $.cookie("lng") != null){
				window.location.href = '/restaurants'
			}	
		},300);
		
		return false;
	})
	
	$('.btn_agree, .btn_disagree').live('click', function(){
		$btn_obj = $(this)
		$status_obj = $(this).parent('.op_btns').prev('.op_status')
		$bg_url = "url('images/op_btns.png')"
		$url = $btn_obj.attr('id').replace(/_/g,'/')

		$.getJSON($url, function(json){

			if (json.result == 1) {
				
				//buttons animation
				if ($btn_obj.hasClass('btn_agree')) {$status_obj.css('background', $bg_url + " 0 -56px")}
				if ($btn_obj.hasClass('btn_disagree')) {$status_obj.css('background', $bg_url + "0 -112px")}
				$btn_obj.parent('.op_btns').fadeOut()
				$status_obj.slideDown()
				
				//update stats
				update_feed_stats($status_obj, json)

			} else {
				window.location.href = json.url
			}
			
		});
		return false;
	})
	
	$('.op_status').live('click', function(){
		$status_obj = $(this)
		$.getJSON(this.href, function(json){
			if (json.result == 1) {
				update_feed_stats($status_obj, json)
			}
		});	
		$status_obj.fadeOut()
		$status_obj.next('.op_btns').fadeIn()
		return false;
	})
	
	
	$('.btn_agree_d, .btn_disagree_d').live('click', function(){		
		$status_obj = $(this).parent('.op_btns_d').prev('.op_status_d')
		$btn_obj = $(this)
		$bg_url = "url('/images/td-choise-buttons.png')"
		
		$.getJSON(this.href, function(json){
			if (json.result == 1) {
				
				//buttons animation
				if ($btn_obj.hasClass('btn_agree_d')) {$status_obj.css('background', $bg_url+" 5px -50px")}
				if ($btn_obj.hasClass('btn_disagree_d')) {$status_obj.css('background', $bg_url+" 5px -100px")}
				$btn_obj.parent('.op_btns_d').fadeOut()
				$status_obj.slideDown()
				
				//update stats
				update_dish_stats($status_obj, json)
				
			} else {
				window.location.href = json.url
			}
			
		});
		return false;
	})
	
	$('.op_status_d').live('click', function(){
		$status_obj = $(this)
		$.getJSON(this.href, function(json){
			if (json.result == 1) {
				update_dish_stats($status_obj, json)
			}
		});	
		$status_obj.fadeOut()
		$status_obj.next('.op_btns_d').fadeIn()
		return false;
	})
	
	$('.users').live('tap', function(event){
		swipe_users('left',$(this))
	})
		
	$('.users').live('swipeleft', function(event){
		swipe_users('left',$(this))
	})
	
	$('.users').live('swiperight', function(event){
		swipe_users('right',$(this))
	})
	
	
	$('.more_info').live('swipeleft', function(event){
		$(this).addClass('swipe')
		
		map_canvas_id = $(this).find(".map_canvas").attr('id')		
		$.getJSON(map_canvas_id.replace(/_/g,'/'), function(json){
			if (json != 0) {
				setTimeout(function(){
					load_map([[json.place, json.lat, json.lng, json.flag]], map_canvas_id)
				},100)
			}
		})
		
	})
	
	$('.map_canvas').live('swiperight', function(event){
		event.preventDefault();
		event.stopPropagation();
	})
	
	$('.more_place_info').live('swiperight', function(event){
		$(this).parent('.more_info').removeClass('swipe')
		$(this).find(".map_canvas").children().remove()		
	})
	
	$('.dish .rating').live('swipeleft', function(event){
		$element = $(this);
		$div = $(this).next('.dish_info')		
		swipe_info($element, $div, 'left')
	})
	
	$('.dish_info').live('swiperight', function(event){
		
		$element = $(this);
		$div = $(this).prev('.rating')
		swipe_info($element, $div, 'right')
	})
	
})


function getLocation(pos)
{
	$.cookie("lat", pos.coords.latitude);
	$.cookie("lng", pos.coords.longitude);
}
function unknownLocation()
{
  console.log('Could not find location');
}

function update_dish_stats(element, data) {
	$stats = element.prev('.stats')
	$stats.children('.like').html(data.likes)
	$stats.children('.dislike').html(data.dislikes)
	
	element.parent('.dish_info').prev('.rating').children('span').html(data.rating)
}


function update_feed_stats(element, data) {
	
	$rrinfo_stats = element.prev('.urinfo').prev('.rrinfo').children('.stats')
	$rrinfo_stats.children('.likes').html(data.likes)
	$rrinfo_stats.children('.users').html(data.users)
	$rrinfo_stats.children('.photos').html(data.photos)
	
	element.prev('.urinfo').children('.users').children('.num').children('span').html(data.agree)
	element.prev('.urinfo').children('.stats').children('.disagree_count').children('span').html(data.disagree)

	$more_place_info = element.next('.op_btns').next('.more_place_info').children('.content').children('.info')
	$more_place_info.children('.like').html(data.likes)
	$more_place_info.children('.dislike').html(data.dislikes)
	
}

function swipe_info(element, div, direction) {
	if (direction == 'left'){
		if (parseInt(element.css('right'),10) == 0){
			element.animate({right: element.parent().outerWidth()}, 300);
			div.animate({left:0}, 220);
		}
	}
	if (direction == 'right'){
		if (parseInt(element.css('left'),10) == 0){
			$div.animate({right:0}, 300)
			$element.animate({left:element.outerWidth()}, 300)
		}
	}
}

function swipe_users(direction, object) {
	if (direction == 'left') {
		object.children('.num').fadeOut()
		object.children('.text').fadeOut()
		object.prev('.stats').fadeOut()
		object.animate({width: '254px'}, 300, function() {
			object.children('.profiles').fadeIn();
		});

	}
	if (direction == 'right') {
		object.animate({width: '84px'}, 300,  function() {
			object.children('.profiles').fadeOut()
			object.children('.num').fadeIn()
			object.children('.text').fadeIn()
		});
		object.prev('.stats').fadeIn()
	}
}

function load_map(markers, element_id) {
  var mapOptions = {
		mapTypeControl: false,
		streetViewControl: false,
		mapTypeId: google.maps.MapTypeId.ROADMAP,
		maxZoom: 15,
		center: new google.maps.LatLng(0,0)
  }
  map = new google.maps.Map(document.getElementById(element_id),mapOptions);

	setMarkers(map, markers);
}

// Add markers to the map
function setMarkers(map, locations) {
  // Add markers to the map
  // Marker sizes are expressed as a Size of X,Y
  // where the origin of the image (0,0) is located
  // in the top left of the image.

  // Origins, anchor positions and coordinates of the marker
  // increase in the X direction to the right and in
  // the Y direction down.
  var image = new google.maps.MarkerImage('http://dish.fm/images/mapPointer.png',
      // This marker is 20 pixels wide by 32 pixels tall.
      new google.maps.Size(26, 42),
      // The origin for this image is 0,0.
      new google.maps.Point(0,0),
      // The anchor for this image is the base of the flagpole at 0,32.
      new google.maps.Point(0, 42));
  // var shadow = new google.maps.MarkerImage('http://code.google.com/intl/ru-RU/apis/maps/documentation/javascript/examples/images/beachflag_shadow.png',
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
  for (var i = 0; i < locations.length; i++) {
    var beach = locations[i];
    var myLatLng = new google.maps.LatLng(beach[1], beach[2]);
    var marker = new google.maps.Marker({
        position: myLatLng,
        map: map,
        icon: image,
        shape: shape,
        title: beach[0],
        zIndex: beach[3]
    });
		bounds.extend(myLatLng);
  }
	map.fitBounds(bounds);
}