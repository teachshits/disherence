class RestaurantsController < ApplicationController
  
  def index
    @restaurant = Restaurant.limit(50)
    @restaurant = @restaurant.by_distance(cookies[:lat], cookies[:lng]) if cookies[:lat] && cookies[:lng]
  end
  
  def show
    @restaurant = Restaurant.find_by_id(params[:id])
  end
  
end
