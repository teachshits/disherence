module ReviewsHelper
  
  def awesome_buttons(user, dish)
    op_btns_add_class = ''
    status_add_class = ''
    
    if user && dish && review = Review.find_by_dish_id_and_user_id(dish.id,user.id)
      op_btns_add_class = ' hidden'
      status_add_class = review.opinion == true ? ' like' :  ' dislike'
    end
    
    #     raw "<div class=\"op_status_d#{status_add_class}\" href=\"/reviews/destroy/#{dish.id}\"><img class=\"trsp\" src=\"/images/trsp.gif\"/></div>
    # <div class=\"op_btns_d#{op_btns_add_class}\">
    #   <div class=\"btn_agree_d\" id=\"_reviews_awesome_#{dish.id}\"><img class=\"trsp\" src=\"/images/trsp.gif\"/></div>
    #   <div class=\"btn_disagree_d\" id=\"_reviews_awful_#{dish.id}\"><img class=\"trsp\" src=\"/images/trsp.gif\"/></div>
    # </div>"
		
		raw "
    		<div class=\"status_aw\"><img class=\"trsp_status\" src=\"images/trsp_status.gif\" /></div>
    		<div class=\"btn_agree_aw\"><img class=\"trsp_btn\" src=\"images/trsp_btn.gif\" /></div>
    		<div class=\"btn_disagree_aw\"><img class=\"trsp_btn\" src=\"images/trsp_btn.gif\" /></div>
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
  
end