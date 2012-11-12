module ApplicationHelper
  
  def user_picture
    if session[:user]
      raw "<div id=\"user_img_profile\" style=\"background-image: url('#{session[:user].photo}')\"></div>"
    end
  end
  
  def fb_opengraph_meta_tag
    
    if @share_obj
      domain = "http://demo.disherence.com"
      app_id = '361774547226492'
    
      
      if @share_obj[:name] = 'restaurant' && restaurant = Restaurant.find_by_id(@share_obj[:id])
        object = 'restaurant'
        title = "top dishes in #{restaurant.name}"
        url = "#{domain}/restaurants/#{@share_obj[:id]}"
            
        dish = Dish.where("restaurant_id = ? AND photos > 0 ",params[:id]).first
        
        if review = Review.where("dish_id = ? AND remote_photo IS NOT NULL", dish.id).first
          image = review.remote_photo
        elsif review = Review.where("dish_id = ? AND local_photo IS NOT NULL", dish.id).first
          image = review.local_photo
        end
    
      elsif @share_obj[:name] = 'dish' && dish = Dish.find_by_id(@share_obj[:id])
        object = 'dish'
        title = "#{dish.name} @ #{dish.restaurant.name}"
        url = "#{domain}/reviews/show/#{@share_obj[:id]}"
        
        image = dish.reviews.where('remote_photo IS NOT NULL').first.remote_photo
        
      end
    
      raw %Q{
        <meta property="fb:app_id" content="#{app_id}" /> 
        <meta property="og:type"   content="disherence:#{object}" /> 
        <meta property="og:url"    content="#{url}" /> 
        <meta property="og:title"  content="#{title}" /> 
        <meta property="og:image"  content="#{image}" />
      }
    end
  end
  
end
