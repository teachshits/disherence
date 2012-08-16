r_info = []
markerList = []
infoBubbleList = []

$(document).ready(function() {
	
	// $(".restaurant_link").live('tap', function(event){
	// 	event.preventDefault();
	// 	href = $(this).attr('href')
	// 	$.ajax({
	//         url: href,
	//         type: 'get',
	//         dataType: 'script',
	//         success: function() {
	//           loading=false;
	// 				setTimeout(function () {
	// 						myScroll.refresh();
	// 						myScroll.scrollTo(0,0,0)
	// 					}, 0);
	//         }
	//     })
	// })
	
	// if ($("#search_map_canvas").length > 0){
		navigator.geolocation.getCurrentPosition(getLocation, unknownLocation);
	// 	setInterval(function(){
	// 		if ($.cookie("lat") != null && $.cookie("lng") != null){
	// 			$.ajax({
	// 	        url: '/restaurants/index',
	// 	        type: 'get',
	// 	        dataType: 'script',
	// 	        success: function() {
	// 	          loading=false;
	// 						setTimeout(function () {
	// 								myScroll.refresh();
	// 								myScroll.scrollTo(0,0,0)
	// 							}, 0);
	// 	        }
	// 	    })
	// 		}
	// 	},200);
	// }
	
	$(".map_link").live('tap', function(event){
		event.preventDefault();
		console.log($(this).attr('href'))
	})
	
	
	$(".close_map").live('tap', function(event){
		event.preventDefault();
		$('#search_map_canvas').removeClass('expand_search_map_canvas')
		$(this).addClass('hidden')
	})
	
	if ($("#map_canvas").length > 0){
		map = load_map('map_canvas')
		id = $('.flag_content:first').attr('id')	
		setMarkers(map, [[r_info[id]['name'], r_info[id]['lat'], r_info[id]['lng'], 1]])
	}
	
	$('.restaurant name').live('tap', function(event){
		event.preventDefault();
		event.stopPropagation();
	})
	
	$('#search_map_canvas').live('tap', function(event){
		$(this).addClass('expand_search_map_canvas')
		$('.close_map').removeClass('hidden')
		event.preventDefault();
		event.stopPropagation();
	})
	
	// Restauants button
	$('#resataurants_button').live('tap', function(){
		navigator.geolocation.getCurrentPosition(getLocation, unknownLocation);
		setInterval(function(){
			if ($.cookie("lat") != null && $.cookie("lng") != null){
			// 	$.ajax({
			// 		        url: '/restaurants',
			// 		        type: 'get',
			// 		        dataType: 'script',
			// 		        success: function() {
			// 		          loading=false;
			// 				setTimeout(function () {
			// 						myScroll.refresh();
			// 						flag = true;
			// 				}, 0);
			// 		        }
			// 		    })
				window.location.href = '/restaurants'
			}
		},200);
		return false;
	})
	
	// Restaurant Dish Info slide	
	$('.dish_info_container .rating').live('swipeleft tap', function(event){
		$(this).parent().addClass('slideLeft')
	})
	$('.dish_info_container').live('swiperight', function(event){
		$(this).removeClass('slideLeft')
	})
	$('.dish_info_container').live('tap', function(event){
		event.stopPropagation();
	})
	
	// Restaurant info dish expand
	$('.dish').live('tap', function(){
		$('.dish').not(this).removeClass('expand')
		$(this).toggleClass('expand')
		setTimeout(function () {
				myScroll.refresh();
			}, 300);
	})
	
	// Restaurant info data
	// $(".place_name, .restaurant .name").live('tap', function(){
	// 	event.preventDefault()
	// 	href = $(this).attr('href')		
	// 	$.ajax({
	//         url: href,
	//         type: 'get',
	//         dataType: 'script',
	//         success: function() {
	//           loading=false;
	// 				setTimeout(function () {
	// 						myScroll.refresh();
	// 						myScroll.scrollTo(0,0,0)
	// 					}, 0);
	//         }
	//     })
	// })
	
	if ($("#wrapper").length > 0){
		document.ontouchmove = function(e) {e.preventDefault()}
		$('.users').children('.profiles').each(function(index, item){ item.ontouchmove = function(e) {e.stopPropagation()} })
		
		var flag = true
		var page = 1
		v_height = document.getElementById('wrapper').scrollHeight

		myScroll = new iScroll('wrapper', { 
			scrollbarClass: 'myScrollbar', 
			onBeforeScrollStart: function() {} ,
			// 			onScrollMove:  function() {
			// 
			// 				if (v_height * page + myScroll.y < 700 && flag == true) {
			// 				flag = false; 
			// 				console.log(page)
			// 				page++;
			// 				$.ajax({
			// 		        url: '/reviews?page=' + page,
			// 		        type: 'get',
			// 		        dataType: 'script',
			// 		        success: function() {
			// 		          loading=false;
			// 							setTimeout(function () {
			// 									myScroll.refresh();
			// 									myScroll.scrollTo(0,0,0)
			// 									flag = true;
			// 							}, 0);
			// 		        }
			// 		    })
			// 			}}
		})		
	}
	
	$('.flag_content').live('swipeleft', function(){
		
		$('.dish_info').removeClass('swipe')
		$(this).closest('.dish_info').addClass('swipe')		
		current_div = $(this)
		
		setTimeout(
			function(){
				id = current_div.attr('id')	
				setMarkers(map, [[r_info[id]['name'], r_info[id]['lat'], r_info[id]['lng'], 1]])
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
	
	// Awesome && Awful Buttons
	$('.btn_agree_d, .btn_disagree_d').live('tap', function(){		
		$status_obj = $(this).parent('.op_btns_d').prev('.op_status_d')
		$bg_url = "url('/images/td-choise-buttons.png')"
		
		//buttons animation
		if ($(this).hasClass('btn_agree_d')) {
			$status_obj.addClass('set_like')
			$(this).prev('.stats').children('.like').html(parseInt($(this)) + 1)
		}
		
		if ($(this).hasClass('btn_disagree_d')) {
			$status_obj.addClass('set_dislike')
			$(this).prev('.stats').children('.dislike').html(parseInt($(this)) + 1)
		}		
		//update stats
		// update_dish_stats($status_obj, json)
	})
	
	$('.op_status_d').live('tap', function(){
		// update_dish_stats($(this), json)	
		$(this).fadeOut()
		$(this).next('.op_btns_d').fadeIn()
		return false;
	})	
	
	// Awesome && Awfull Buttons
	$('.btn_agree_aw, .btn_disagree_aw').live('tap', function(){
		event.preventDefault()
		event.stopPropagation()
		
		if (this.className == 'btn_agree_aw') {
			$(this).prev('.status_aw').addClass('set_agree_aw')
			el = $(this).prev().prev('.review')
			el.find('.users .num').text('+' + (parseInt(el.find('.users .num').text()) + 1))
			
			if (el.find('.user_info .opinion').text().indexOf('Awesome') != -1) {
				el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) + 1)
			}
			
		} else {
			$(this).prev().prev('.status_aw').addClass('set_disagree_aw')
			el = $(this).prev().prev().prev('.review')
			el.find('.disagree').text('#' + (parseInt(el.find('.disagree').text().replace(/\D/g, '')) + 1) + ' user(s) disagree')
			
			if (el.find('.user_info .opinion').text().indexOf('Awful') != -1) {
				el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) + 1)
			}
		}
		
		el.find('.dish_info .profiles').text(parseInt(el.find('.dish_info .profiles').text()) + 1)
	})
	
	$('.status_aw').live('tap', function(event){
		event.preventDefault()
		event.stopPropagation()
		
		$(this).addClass('opacity_zero')
		el = $(this).prev('.review')

		
		if (this.className.indexOf('set_agree_aw') != -1) {
			el.find('.users .num').text('+' + (parseInt(el.find('.users .num').text()) - 1))

			if (el.find('.user_info .opinion').text().indexOf('Awesome') != -1) {		
				el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) - 1)
			}
		
			fade = $(this)
			setTimeout(function(){fade.removeClass('set_agree_aw').removeClass('opacity_zero')}, 400)
			
		} else {
			el.find('.disagree').text('#' + (parseInt(el.find('.disagree').text().replace(/\D/g, '')) - 1) + ' user(s) disagree')
			
			if (el.find('.user_info .opinion').text().indexOf('Awful') != -1) {
				el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) - 1)
			}

			fade = $(this)
			setTimeout(function(){fade.removeClass('set_disagree_aw').removeClass('opacity_zero')}, 400)
			
		}
		el.find('.dish_info .profiles').text(parseInt(el.find('.dish_info .profiles').text()) - 1)
	})
	
// Agree && Disagree Buttons
$('.btn_agree, .btn_disagree').live('tap', function(){
	event.preventDefault()
	event.stopPropagation()
	
	if (this.className == 'btn_agree') {
		
		$(this).prev('.status').addClass('set_agree')
		el = $(this).prev().prev('.review')
		$opinion_popup = el.children('.opinion_popup')
		
		el.find('.users .num').text('+' + (parseInt(el.find('.users .num').text()) + 1))
		
		if (el.find('.user_info .opinion').text().indexOf('Awesome') != -1) {
			el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) + 1)
			$opinion_popup.text('You think it`s awesome').addClass('opinionesome')
			setTimeout("$opinion_popup.removeClass('opinionesome')",1500);	
		} else {
			$opinion_popup.text('You think it`s awful').addClass('opinionful')
			setTimeout("$opinion_popup.removeClass('opinionful')",1500);	
		}
		
	} else {

		$(this).prev().prev('.status').addClass('set_disagree')
		el = $(this).prev().prev().prev('.review')
		$opinion_popup = el.children('.opinion_popup')
		
		el.find('.disagree').text('#' + (parseInt(el.find('.disagree').text().replace(/\D/g, '')) + 1) + ' user(s) disagree')
		
		if (el.find('.user_info .opinion').text().indexOf('Awful') != -1) {
			el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) + 1)
			$opinion_popup.text('You think it`s awesome').addClass('opinionesome')
			setTimeout("$opinion_popup.removeClass('opinionesome')",1500);	
		} else {
			$opinion_popup.text('You think it`s awful').addClass('opinionful')
			setTimeout("$opinion_popup.removeClass('opinionful')",1500);	
		}
	}
	
	el.find('.dish_info .profiles').text(parseInt(el.find('.dish_info .profiles').text()) + 1)
})

$('.status').live('tap', function(event){
	event.preventDefault()
	event.stopPropagation()
	
	$(this).addClass('opacity_zero')
	el = $(this).prev('.review')

	
	if (this.className.indexOf('set_agree') != -1) {
		el.find('.users .num').text('+' + (parseInt(el.find('.users .num').text()) - 1))

		if (el.find('.user_info .opinion').text().indexOf('Awesome') != -1) {		
			el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) - 1)
		}
	
		fade = $(this)
		setTimeout(function(){fade.removeClass('set_agree').removeClass('opacity_zero')}, 400)
		
	} else {
		el.find('.disagree').text('#' + (parseInt(el.find('.disagree').text().replace(/\D/g, '')) - 1) + ' user(s) disagree')
		
		if (el.find('.user_info .opinion').text().indexOf('Awful') != -1) {
			el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) - 1)
		}

		fade = $(this)
		setTimeout(function(){fade.removeClass('set_disagree').removeClass('opacity_zero')}, 400)
		
	}
	el.find('.dish_info .profiles').text(parseInt(el.find('.dish_info .profiles').text()) - 1)
})

});


function getLocation(pos)
{
	$.cookie("lat", pos.coords.latitude);
	$.cookie("lng", pos.coords.longitude);
}

function unknownLocation()
{
  console.log('Could not find location');
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
	markerList = [];
}

// Add markers to the map
function setMarkers(map, locations) {
	if (typeof markerList != 'undefined') {clearMarkers()}
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
			
		google.maps.event.addListener(marker, 'click', (function(marker, i) {
	    return function() {

				if (typeof infoBubble != 'undefined') {
					infoBubble.close();
				}

        infoBubble = new InfoBubble({
          map: map,
          content: '<div class="phoneytext"><a class="map_link" href="/restaurants/show/'+locations[i][4]+'">'+locations[i][0]+'</a></div>',
          position: new google.maps.LatLng(parseFloat(locations[i][1]) + 0.0009, locations[i][2] - 0.0002),
          shadowStyle: 1,
          padding: 0,
          backgroundColor: 'rgb(57,57,57)',
          borderRadius: 4,
          arrowSize: 0,
          borderWidth: 1,
          borderColor: '#2c2c2c',
          disableAutoPan: true,
          hideCloseButton: true,
          arrowPosition: 30,
          backgroundClassName: 'phoney',
          arrowStyle: 2
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