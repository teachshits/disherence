class ApiController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  def share
    if ( !params[:token].blank? || !session[:user].blank?) && !params[:restaurant_id].blank?      
      
      params[:token] = session[:user].token if params[:token].blank?
    
      if params[:provider] == 'facebook'
        User.share_on_facebook(params[:token], params[:restaurant_id], params[:text]) 
      elsif params[:provider] == 'twitter'
        User.share_on_twitter(params[:token], params[:restaurant_id], params[:text]) 
      end
      
      return render :json => { :result => 1}
    end
    
    return render :json => { :result => 0}
  end
  
  
  def get_user_profile
    if user = User.find_by_token(params[:token])      
      data = Review.where(:user_id => user.id)
    end
        
    return render :json => {
      :user => user.as_json,
      :reviews => data.as_json(:only => [:id, :remote_photo, :photo, :opinion], :include => [:dish => {:only => [:name], :include => [:restaurant => {:only => [:name, :address, :id, :bill, :cuisine, :lat, :lng, :yelp_reviews_count, :yelp_rating]}]}])
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
    
    if !params[:search].blank?
      data = data.where("name LIKE ?", "%#{params[:search]}%")   
    else
      data = data.joins(:dishes).where("dishes.likes > 0").group("restaurants.id")
    end
    
    data = data.limit(params[:limit]).offset(params[:offset])
    
    return render :json => {
      :restaurants => data.as_json
    }
  end
  
  def get_best_dishes
    if params[:restaurant_id]
      
      params[:limit] ||= 25
      params[:offset] ||= 0
      
      data = Dish.where("restaurant_id = ? AND (likes > 0 || photos > 0)", params[:restaurant_id]).order("likes - dislikes DESC").limit(params[:limit]).offset(params[:offset])
      
      data.each do |dish|
        dish.opinion = 3
        if !params[:token].blank? && user = User.find_by_token(params[:token])
          if review = Review.find_by_user_id_and_dish_id(user.id, dish.id)
            dish.opinion = review.opinion
          end
        end
      end
    end
    return render :json => {
      :best_dishes => data || 0
    }
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
    Review.create(:local_photo => params[:local_photo], :dish_id => params[:dish_id], :user_id => User.find_by_token(params[:token]).id, :opinion => true)

    if dish = Dish.find_by_id(params[:dish_id])
      if user = User.find_by_token(params[:token])
        r = Review.awesome(dish.id, user.id, params[:local_photo])        
        
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
        r = Review.awful(dish_id, user.id, params[:photo])
        
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
  
  def delete_review
    if user = User.find_by_token(params[:token])
      if !params[:dish_id].blank? && review = Review.find_by_user_id_and_dish_id(user.id, params[:dish_id])
        review.destroy
        return render :json => { :result => 1}
      end
      return render :json => { :result => 0}
    end
    return render :json => { :result => 0}
  end  
  
end
