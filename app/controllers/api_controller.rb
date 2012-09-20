class ApiController < ApplicationController
  
  def get_user_reviews
    if params[:user_id]
      data = Review.where(:user_id => params[:user_id])
    end
    
    return render :json => {
      :reviews => data.as_json
    }
  end
  
  
  def get_restaurants
    params[:limit] ||= 25
    params[:offset] ||= 0
    
    unless params[:lat] && params[:lng]
      params[:lat] = 40.7
      params[:lng] = -74
    end
    
    if params[:bounds]
      data = Restaurant.bounds(params[:bounds])
    else
      data = Restaurant.by_distance(params[:lat], params[:lng])
    end
    
    data = data.where("name LIKE ?", "%#{params[:search]}%") unless params[:search].blank?
    data = data.limit(params[:limit]).offset(params[:offset])
    
    return render :json => {
      :restaurants => data.as_json
    }
  end
  
  def get_best_dishes
    if params[:restaurant_id]
      data = Dish.where("restaurant_id = ? AND (likes > 0 || remote_photo IS NOT NULL)", params[:restaurant_id]).order("likes - dislikes DESC")
      
      return render :json => {
        :best_dishes => data.as_json
      }
    end
  end
  
  # http://0.0.0.0:3000/api/set_opinion?opinion=1&user_id=14563&dish_id=50
  def set_opinion
    if params[:opinion] && params[:user_id] && params[:dish_id]
      data = Review.awesome(params[:dish_id], params[:user_id]) if params[:opinion] == '1'
      data = Review.awful(params[:dish_id], params[:user_id]) if params[:opinion] == '0'
    end
    
    return render :json => {:data => data || nil}
  end
  
  def authenticate_user
    
    if params[:provider] == 'facebook' && params[:access_token]
      session = User.authenticate_by_facebook(:fb_access_token => params[:access_token], :fb_valid_to => params[:fb_valid_to]) 
    elsif params[:provider] == 'twitter' && params[:oauth_token] && params[:oauth_token_secret]
      session = User.authenticate_by_twitter(params[:oauth_token], params[:oauth_token_secret], params[:email])
    end
    
    return render :json => {
          :session => session || nil,
    }
  end
  
  def awesome
    if dish_id = params[:dish_id]
      if user = User.find_by_token(params[:token])
        r = Review.awesome(dish_id,user.id)        
        
        likes = r.dish.likes
        dislikes = r.dish.dislikes
        rating = (r.dish.likes * 100)/r.dish.restaurant.dishes.sum(:likes)
        
        return render :json => {:result => 1}
      else
        return render :json => {:result => 0}
      end
      return render :json => {:result => 2}
    end
    return render :json => {:result => 3}
  end
  
  def awful
    if dish_id = params[:dish_id]
      if user = User.find_by_token(params[:token])
        r = Review.awful(dish_id,user.id)
        
        likes = r.dish.likes
        dislikes = r.dish.dislikes
        rating = (r.dish.likes * 100)/r.dish.restaurant.dishes.sum(:likes)
        
        return render :json => {"result" => 1}
      else
        return render :json => {"result" => 0}
      end
      return render :json => {"result" => 0}
    end
    return render :json => {"result" => 0}
  end
  
end
