class RestaurantsController < ApplicationController
  
  def index
    @restaurants = Restaurant.limit(20)
    @restaurants = @restaurants.by_distance(cookies[:lat], cookies[:lng]) if cookies[:lat] && cookies[:lng]
    
    @restaurants_info = ""
    i = 0
    @restaurants.each do |r|
      id = r.id
      name = r.name.gsub(/'/, "\\\\'")
      lat = r.lat
      lng = r.lng 
      @restaurants_info += "r_info = [];"
      @restaurants_info += "r_info[#{i}][1] = '#{name}';"
      @restaurants_info += "r_info[#{i}][2] = '#{lat}';"
      @restaurants_info += "r_info[#{i}][3] = '#{lng}';"
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
