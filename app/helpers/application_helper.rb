module ApplicationHelper
  
  def user_picture
    if session[:user]
      raw "<div id=\"user_img_profile\" style=\"background-image: url('#{session[:user].photo}')\"></div>"
    end
  end
  
  def fb_opengraph_meta_tag
    if restaurant = Restaurant.find_by_id(params[:id])
      
      domain = "http://demo.disherence.com"
      app_id = '361774547226492'
      object = 'restaurant'
      
      # url = "#{domain}#{eval "#{type}_path(#{@fb_obj.id})" }"
      
      title = restaurant.name
      url = "#{domain}/restaurants/#{params[:id]}"
            
      dish = Dish.where("restaurant_id = ? AND photos > 0 ",params[:id]).first
      review = Review.where("dish_id = ? AND remote_photo IS NOT NULL", dish.id).first
      image = review.remote_photo
      
      best_dishes = []
      restaurant.dishes.where('photos > 0').order('likes DESC').each do |d|
        if best_dishes.count < 1 && review = d.reviews.where('remote_photo IS NOT NULL').first
          best_dishes.push("<meta property=\"disherence:best_dishes\"  content=\"#{domain}/reviews/show/#{review.dish_id}\" />")
        end
      end
      
      raw %Q{
        <meta property="fb:app_id" content="#{app_id}" /> 
        <meta property="og:type"   content="disherence:#{object}" /> 
        <meta property="og:url"    content="#{url}" /> 
        <meta property="og:title"  content="#{title}" /> 
        <meta property="og:image"  content="#{image}" />
        #{best_dishes.join("\n")}
      }
    end
  end
  
  
end
