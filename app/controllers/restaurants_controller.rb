class RestaurantsController < ApplicationController
  
  def index
    @restaurant = Restaurant.limit(20)
    @restaurant = @restaurant.by_distance(cookies[:lat], cookies[:lng]) if cookies[:lat] && cookies[:lng]
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
