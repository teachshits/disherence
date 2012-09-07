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
    
    data = Restaurant.by_distance(params[:lat], params[:lng]).limit(params[:limit]).offset(params[:offset])
    data = data.where("name LIKE ?", "%#{params[:search]}%") unless params[:search].blank?
    
    return render :json => {
      :restaurants => data.as_json
    }
  end
  
  def get_best_dishes
    if params[:restaurant_id]
      data = Dish.where(:restaurant_id => params[:restaurant_id]).order("likes - dislikes DESC")
      
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
    

    if params[:push_token] && session[:user_id]
      User.link_push_token(params[:push_token], session[:user_id])
    
      if device = APN::Device.find_by_token_and_user_id(params[:push_token], session[:user_id])
        device.active = 1
        device.save
      end
      
    end
    
    return render :json => {
          :session => session || nil,
    }
    
  end
end
