module ReviewsHelper
  
  def dish_likes(user, dish)
    if user && review = Review.find_by_user_id_and_dish_id(user.id, dish.id)
      raw review.opinion == true ? 'You <span class="like_it">like it</span>' : 'You <span class="hate_it">hate it</span>'
    else
      dish.likes >= 1000 ? ">#{dish.likes.to_s[0]}K" : dish.likes
    end
  end
  
  def yelp_rating(restaurant)
    rating = []
    
    restaurant.yelp_rating.to_i.times do
			rating.push('<div class="star fill"></div>')
    end

	  if restaurant.yelp_rating.to_f - restaurant.yelp_rating.to_i != 0
			rating.push('<div class="star half"></div>')
			rating_with_half = restaurant.yelp_rating.to_i + 1
		else
		  rating_with_half = restaurant.yelp_rating.to_i
		end

		(5 - rating_with_half).times do
			rating.push('<div class="star empty"></div>')
		end
		
		raw rating.join
  end
  
  
  def awesome_buttons(user, dish)
    op_btns_add_class = ''
    status_add_class = ''
    
    if user && dish && review = Review.find_by_dish_id_and_user_id(dish.id,user.id)
      status_add_class = review.opinion == true ? ' set_agree_aw' :  ' set_disagree_aw'
    end
		
		raw "
		    <div class=\"btn_container\">
      		<a class=\"status_aw#{status_add_class}\" href=\"/reviews/destroy/#{dish.id}\"><img class=\"trsp_status\" src=\"/images/trsp_status.gif\" /></a>
      		<a class=\"btn_agree_aw\" href=\"/reviews/awesome/#{dish.id}\"><img class=\"trsp_btn\" src=\"/images/trsp_btn.gif\" /></a>
      		<a class=\"btn_disagree_aw\" href=\"/reviews/awful/#{dish.id}\"><img class=\"trsp_btn\" src=\"/images/trsp_btn.gif\" /></a>
      	</div>
		"
  end
  
  def agree_buttons(user, review)
    op_btns_add_class = ''
    status_add_class = ''
    
    if user && agree = review.agree?(user.id)
      op_btns_add_class = ' hidden'
      status_add_class = agree == 1 ? ' agree' :  ' disagree'
    end
    
		raw "<a class=\"op_status#{status_add_class}\" id=\"_reviews_destroy_#{review.dish_id}_#{review.id}\" href=\"/reviews/destroy/#{review.dish_id}/#{review.id}\"><img class=\"trsp\" src=\"/images/trsp.gif\"/></a>
		<div class=\"op_btns#{op_btns_add_class}\">
			<a class=\"btn_agree\" id=\"_reviews_agree_#{review.id}\" href=\"/reviews/agree/#{review.id}\"><img class=\"trsp\" src=\"/images/trsp.gif\"/></a>
			<a class=\"btn_disagree\" id=\"_reviews_disagree_#{review.id}\" href=\"/reviews/disagree/#{review.id}\"><img class=\"trsp\" src=\"/images/trsp.gif\"/></a>
		</div>"
  end
  
  def users_agreed(user, review)
    profiles = []
    Review.where('dish_id = ? AND user_id != ? AND opinion = ?', review.dish_id, review.user_id, review.opinion).each do |rw|
      profiles.push("<a href= \"#\" class=\"profile\" style=\"background-image: url('#{rw.user.photo}')\"></a>")
    end
    raw "#{profiles.join("\n")}"
  end
  
  def review_opposite(review)
    info = {}
    if r = Review.where('id = ? AND opinion = 0', review.id).order('created_at DESC').first
      info[:photo] = r.user.photo
      info[:name] = r.user.name
    else
      info[:photo] = review.user.photo
      info[:name] = review.user.name
    end
    info
  end  
  
end