class RestaurantsController < ApplicationController
  
  def show
    if @restaurant = Restaurant.find_by_id(params[:id])

    end
  end
  
end
