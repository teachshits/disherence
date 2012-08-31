class ApiController < ApplicationController
  
  def get_restaurants
    params[:limit] ||= 25
    params[:offset] ||= 0
    
    unless params[:lat] && params[:lng]
      params[:lat] = 40.7
      params[:lng] = -74
    end
    
    data = Restaurant.by_distance(params[:lat], params[:lng]).limit(params[:limit]).offset(params[:offset])
    
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
  
  
  
end
