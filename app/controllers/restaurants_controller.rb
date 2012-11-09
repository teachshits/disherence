class RestaurantsController < ApplicationController
  
  def splashscreen
  end
  
  
  def index
    
    if params[:lat] && params[:lng]
      @lat = params[:lat]
      @lng = params[:lng]
    else
      @lat = cookies[:lat]
      @lng = cookies[:lng]
    end
    
    @restaurants = Restaurant.by_distance(@lat, @lng).limit(15)
    @restaurants = @restaurants.where('name LIKE ?', "%#{params[:search]}%") unless params[:search].blank?
    
    @restaurants.reject! do |res|
      to_reject = true
      res.dishes.each do |dish|
        if dish.reviews.with_photos.size > 0
          to_reject = false
          break;
        end
      end
      to_reject
    end
    
    time = Time.now.to_i
    @restaurants_info = "r_info = [];\n"
    i = 0
    
    @restaurants.each do |r|
      @restaurants_info += "r_info[#{i}] = {};\n"
      @restaurants_info += "r_info[#{i}]['id'] = '#{r.id}';\n"
      @restaurants_info += "r_info[#{i}]['name'] = '#{r.name.gsub(/'/, "\\\\'")}';\n"
      @restaurants_info += "r_info[#{i}]['lat'] = '#{r.lat}';\n"
      @restaurants_info += "r_info[#{i}]['lng'] = '#{r.lng}';\n"
      @restaurants_info += "r_info[#{i}]['rating'] = '<br /><div class=\"s_cont\">#{view_context.yelp_rating(r)}</div>';\n"
      @restaurants_info += "r_info[#{i}]['type'] = '<br />#{r.cuisine}';\n"
      @restaurants_info += "r_info[#{i}]['count'] = '<br />#{@restaurants.count}';\n"
      i += 1
    end  
        
  end
  
  def show
    @restaurant = Restaurant.find_by_id(params[:id])
    @dishes = @restaurant.dishes.where('photos > 0 || likes > 0').order('likes DESC')
    
    if request.env["HTTP_USER_AGENT"].include?('iPhone') || 
       request.env["HTTP_USER_AGENT"].include?('iPad') || 
       request.env["HTTP_USER_AGENT"].include?('Android')
     
      @dishes = @dishes.limit(20)
    end
    
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
      :name => 'restaurant',
      :id => params[:id]
    }
    @restaurant.view_restaurant_fb_action(session[:user]) if session[:user]
    @user_obj = session[:user]
  end
  
  def info
    if r = Restaurant.find_by_id(params[:id])
      return render :json => {
        :place => r.name.gsub(/'/, "\\\\'"),
        :lat => r.lat, 
        :lng => r.lng, 
        :flag => 1}
    else
      return render :json => [0]
    end
  end
  
end
