class RestaurantsController < ApplicationController
  
  def splashscreen
  end
  
  
  def index
    
    if params[:lat] && params[:lng]
      lat = params[:lat]
      lng = params[:lng] 
    else
      lat = cookies[:lat]
      lng = cookies[:lng]
    end
    
    @restaurants = Restaurant.limit(15)
    @restaurants = params[:search].blank? ? @restaurants.by_distance(lat, lng) : @restaurants.where('name LIKE ?', "%#{params[:search]}%")
    
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
    
    @restaurants_info = " "
    i = 0
    
    @restaurants.each do |r|
      @restaurants_info += "r_info[#{i}] = {};\n"
      @restaurants_info += "r_info[#{i}]['id'] = '#{r.id}';\n"
      @restaurants_info += "r_info[#{i}]['name'] = '#{r.name.gsub(/'/, "\\\\'")}';\n"
      @restaurants_info += "r_info[#{i}]['lat'] = '#{r.lat}';\n"
      @restaurants_info += "r_info[#{i}]['lng'] = '#{r.lng}';\n"
      @restaurants_info += "r_info[#{i}]['rating'] = '<br /><div class=\"s_cont\">#{view_context.yelp_rating(r)}</div>';\n"
      @restaurants_info += "r_info[#{i}]['type'] = '<br />#{r.cuisine}';\n"
      i += 1
    end  
  end
  
  def show
    @restaurant = Restaurant.find_by_id(params[:id])
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
