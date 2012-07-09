module ReviewsHelper
  
  def awesome_buttons(user, dish)
    op_btns_add_class = ''
    status_add_class = ''
    
    if user && dish && review = Review.find_by_dish_id_and_user_id(dish.id,user.id)
      op_btns_add_class = ' hidden'
      status_add_class = review.opinion == true ? ' like' :  ' dislike'
    end
    
    raw "<a class=\"op_status_d#{status_add_class}\" href=\"/reviews/destroy/#{dish.id}\"><img class=\"trsp\" src=\"/images/trsp.gif\"/></a>
		<div class=\"op_btns_d#{op_btns_add_class}\">
			<a class=\"btn_agree_d\" href=\"/reviews/awesome/#{dish.id}\"></a>
			<a class=\"btn_disagree_d\" href=\"/reviews/awful/#{dish.id}\"></a>
		</div>"
  end
  
  def agree_buttons(user, review)
    op_btns_add_class = ''
    status_add_class = ''
    
    if user && agree = review.agree?(user.id)
      op_btns_add_class = ' hidden'
      status_add_class = agree == 1 ? ' agree' :  ' disagree'
    end
    
		raw "<a class=\"op_status#{status_add_class}\" href=\"/reviews/destroy/#{review.dish_id}/#{review.id}\"><img class=\"trsp\" src=\"/images/trsp.gif\"/></a>
		<div class=\"op_btns#{op_btns_add_class}\">
			<a class=\"btn_agree\" href=\"/reviews/agree/#{review.id}\"></a>
			<a class=\"btn_disagree\" href=\"/reviews/disagree/#{review.id}\"></a>
		</div>"
  end
  
  def users_agreed(user_id, review)
    
    profiles = []
    Review.where('dish_id = ? AND user_id != ?',review.dish_id,review.user_id).each do |rw|
      profiles.push("<a href= \"#\" class=\"profile\" style=\"background-image: url('#{rw.user.photo}')\"></a>") if rw.agree?(user_id) == 1
    end
    
    add_class_hidden = !profiles.any? ? ' hidden' : ''
    
    raw "<div class=\"users#{add_class_hidden}\">
			<div class=\"num\">+<span>#{review.count_agree}</span></div>
			<div class=\"text\">think so</div>
			<div data-scroll=\"x\" class=\"profiles\">
					#{profiles.join("\n")}				
			</div>
		</div>"
  end
  
  
end
