class ReviewsController < ApplicationController
  
  def index
          
    @facebook_app_id = Rails.application.config.facebook_app_id
    @redirect_uri = Rails.application.config.redirect_uri
    
    @reviews = Review.with_photos.where(:opinion => 1).order('RAND()').limit(10)
    @reviews = @reviews.where('user_id != ?', session[:user].id) unless session[:user].nil?
    # @reviews.page params[:page]
    
    @restaurants_info = ""
    @reviews.each do |rw|
      name = rw.dish.restaurant.name.gsub(/'/, "\\\\'")
      lat = rw.dish.restaurant.lat
      lng = rw.dish.restaurant.lng 
      @restaurants_info += "r_info['r_#{rw.id}'] = {};"
      @restaurants_info += "r_info['r_#{rw.id}']['name'] = '#{name}';"
      @restaurants_info += "r_info['r_#{rw.id}']['lat'] = '#{lat}';"
      @restaurants_info += "r_info['r_#{rw.id}']['lng'] = '#{lng}';"
    end
    
    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.xml  { render :xml => @reviews }
    end
    
  end
  
  
  def show
    if @dish = Dish.find_by_id(params[:id])

      @restaurant = Restaurant.find_by_id(@dish.restaurant_id)
    
      url_params = []
      url_params.push("back=1")
      url_params.push("lat=#{cookies[:lat]}")
      url_params.push("lng=#{cookies[:lng]}")
      url_params.push("search=#{cookies[:search]}") unless cookies[:search].blank?
      url_params = url_params.join('&')
    
      @back_url = "restaurants?#{url_params}"
    
      @fb_url = Rails.application.config.fb_auth_url
    
      consumer_key = "XQlhrLVWUJK7q1AK9uTeQ"
      consumer_secret = "M2iDOlkxW8Y7430Q6HgFquY1haZnaEqIVrFhyE0XIo"
        
      consumer = OAuth::Consumer.new(consumer_key, consumer_secret, :site => "http://api.twitter.com", :scheme => :header)    
      request_token = consumer.get_request_token(:oauth_callback => "http://demo.disherence.com/users/auth_callback")
    
      session[:request_token] = request_token.token
      session[:request_secret] = request_token.secret
    
      @tw_url = request_token.authorize_url
      @share_obj = {
        :name => 'dish',
        :id => params[:id]
      }
      
    end    
  end
  
  def awesome
    if dish = Dish.find_by_id(params[:id])
      if user = session[:user]
        r = Review.awesome(dish.id,user.id)        
        
        likes = r.dish.likes
        dislikes = r.dish.dislikes
        rating = (r.dish.likes * 100)/r.dish.restaurant.dishes.sum(:likes)
        
        return render :json => {:result => 1, :likes => likes, :dislikes => dislikes, :rating => rating}
      else
        return render :json => {:result => 0, :url => 1}
      end
    end
  end
  
  def awful
    if dish_id = params[:id]
      if user = session[:user]
        r = Review.awful(dish_id,user.id)
        
        likes = r.dish.likes
        dislikes = r.dish.dislikes
        rating = (r.dish.likes * 100)/r.dish.restaurant.dishes.sum(:likes)
        
        return render :json => {"result" => 1, "likes" => likes, :dislikes => dislikes, :rating => rating}
      else
        return render :json => {"result" => 0, "url" => Rails.application.config.fb_auth_url}
      end
    end
  end
  
  def agree
    if review_id = params[:id]
      if user = session[:user]
        r = Review.agree(review_id,user.id)
        
        disagree = r.opinion == true ? r.dish.dislikes : r.dish.likes
        agree = r.opinion == true ? r.dish.likes - 1 : r.dish.dislikes - 1
        
        return render :json => {
          :result => 1,
          :likes => r.dish.likes, 
          :dislikes => r.dish.dislikes,
          :users => r.dish.likes + r.dish.dislikes,
          :photos => r.dish.photos,
          :agree => agree,
          :disagree => disagree,
        }
      else
        return render :json => {"result" => 0, "url" => Rails.application.config.fb_auth_url}
      end
    end
  end
  
  def disagree
    if review_id = params[:id]
      if user = session[:user]
        r = Review.disagree(review_id,user.id)
        disagree = r.opinion == false ? r.dish.dislikes : r.dish.likes
        agree = r.opinion == false ? r.dish.likes - 1 : r.dish.dislikes - 1
        
        return render :json => {
          :result => 1,
          :likes => r.dish.likes, 
          :dislikes => r.dish.dislikes,
          :users => r.dish.likes + r.dish.dislikes,
          :photos => r.dish.photos,
          :agree => agree,
          :disagree => disagree,
        }
        
      else
        return render :json => {"result" => 0, "url" => Rails.application.config.fb_auth_url}
      end
      
    end
  end
  
  def destroy
    if dish_id = params[:id]
      if user = session[:user]
        
        if rd = Review.find_by_dish_id_and_user_id(dish_id,user.id)
          
          if rw = Review.find_by_id(params[:review_id])
            
            likes = rd.dish.likes
            dislikes = rd.dish.dislikes
            users = rd.dish.likes + rd.dish.dislikes - 1
            photos = rd.dish.photos
            agree = rw.count_agree
            disagree = rw.count_disagree

            rw.agree?(user.id) == 1 ? agree -= 1 : disagree -= 1
            rd.opinion == true ? likes -= 1 : dislikes -= 1
          else
            likes = rd.dish.likes
            dislikes = rd.dish.dislikes
            
            if rd.opinion == true
              rating = ((likes - 1) * 100)/(rd.dish.restaurant.dishes.sum(:likes) - 1)
              likes -= 1
            else
              rating = (likes * 100)/rd.dish.restaurant.dishes.sum(:likes)
              dislikes -= 1
            end

          end
          rd.destroy
          
          return render :json => {
            :result => 1,
            :likes => likes, 
            :dislikes => dislikes,
            :users => users,
            :photos => photos,
            :agree => agree,
            :disagree => disagree,
            :rating => rating || nil
          }
          
        end
      end
      
    end
  end
  
end