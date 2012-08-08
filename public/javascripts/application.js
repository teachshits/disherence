$(document).ready(function() {
	
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
	$('.dish_info .rating').live('swipeleft tap', function(event){
		$(this).parent().addClass('slideLeft')
	})
	
	$('.dish_info').live('swiperight', function(event){
		$(this).removeClass('slideLeft')
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
	$(".place_name").live('click', function(){
		event.preventDefault()		
		$.ajax({
        url: $(this).attr('href'),
        type: 'get',
        dataType: 'script',
        success: function() {
          loading=false;
					setTimeout(function () {
							myScroll.refresh();
						}, 0);
        }
      })
	})
	
	if ($("#wrapper").length > 0){
		document.ontouchmove = function(e) {e.preventDefault()}
		$('.users').children('.profiles').each(function(index, item){ item.ontouchmove = function(e) {e.stopPropagation()} })
		
		var myScroll
		var flag = true
		var page = 1
		v_height = document.getElementById('wrapper').scrollHeight

		myScroll = new iScroll('wrapper', { 
			scrollbarClass: 'myScrollbar', 
			onBeforeScrollStart: null,
			onScrollMove:  function() {

				if (v_height * page + myScroll.y < 700 && flag == true) {
				flag = false; 
				console.log(page)
				page++;
				$.ajax({
		        url: '/reviews?page=' + page,
		        type: 'get',
		        dataType: 'script',
		        success: function() {
		          loading=false;
							setTimeout(function () {
									myScroll.refresh();
									flag = true;
							}, 0);
		        }
		    })
			}}
		})		
	}
	
	$('.flag_content').live('swipeleft', function(){
		$('.dish_info').removeClass('swipe')
		$(this).closest('.dish_info').addClass('swipe')
	})
	

	$('.stats').live('tap', function(){
		num_agree = $(this).next('.users').find('.num').text().replace(/\D/g, '')
		num_disagree = $(this).children('.disagree').text().replace(/\D/g, '')

		$(this).children('.disagree').text('#' + num_agree +  ' user(s) agree')
		$(this).next('.users').find('.num').text('+' + num_disagree)
		
		$(this).next('.users').toggleClass('like').toggleClass('dislike')
		
		stat = $(this).children('.opinion').text().indexOf('Awesome') != -1 ? 'Awful' : 'Awesome'
		$(this).children('.opinion').text('It`s ' + stat)
		
		$(this).prev('.user_photo').find('.photo_like').toggleClass('slide_down')
		$(this).next().find('.profile').toggleClass('hidden')
		
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
	
	// function update_dish_stats(element, data) {
	// 	$stats = element.prev('.stats')
	// 	$stats.children('.like').html(data.likes)
	// 	$stats.children('.dislike').html(data.dislikes)
	// 
	// 	element.parent('.dish_info').prev('.rating').children('span').html(data.rating)
	// }
	
	
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
				$opinion_popup.text('You think it`s awesome').addClass('opinion_awesome')
				setTimeout("$opinion_popup.removeClass('opinion_awesome')",1500);	
			} else {
				$opinion_popup.text('You think it`s awful').addClass('opinion_awful')
				setTimeout("$opinion_popup.removeClass('opinion_awful')",1500);	
			}
			
		} else {

			$(this).prev().prev('.status').addClass('set_disagree')
			el = $(this).prev().prev().prev('.review')
			$opinion_popup = el.children('.opinion_popup')
			
			el.find('.disagree').text('#' + (parseInt(el.find('.disagree').text().replace(/\D/g, '')) + 1) + ' user(s) disagree')
			
			if (el.find('.user_info .opinion').text().indexOf('Awful') != -1) {
				el.find('.dish_info .likes').text(parseInt(el.find('.dish_info .likes').text()) + 1)
				$opinion_popup.text('You think it`s awesome').addClass('opinion_awesome')
				setTimeout("$opinion_popup.removeClass('opinion_awesome')",1500);	
			} else {
				$opinion_popup.text('You think it`s awful').addClass('opinion_awful')
				setTimeout("$opinion_popup.removeClass('opinion_awful')",1500);	
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