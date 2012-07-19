class RestaurantsController < ApplicationController
  
  def index
    @restaurants = Restaurant.limit(20)
    @restaurants = @restaurants.by_distance(cookies[:lat], cookies[:lng]) if cookies[:lat] && cookies[:lng]
    
    @restaurants_info = ""
    @restaurants.each do |r|
      id = r.id
      name = r.name.gsub(/'/, "\\\\'")
      lat = r.lat
      lng = r.lng 
      @restaurants_info += "r_info['r_#{id}'] = {};"
      @restaurants_info += "r_info['r_#{id}']['name'] = '#{name}';"
      @restaurants_info += "r_info['r_#{id}']['lat'] = '#{lat}';"
      @restaurants_info += "r_info['r_#{id}']['lng'] = '#{lng}';"
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
