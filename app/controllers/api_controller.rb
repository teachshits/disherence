class ApiController < ApplicationController
  
  def get_res
    # if params[:lat] && params[:lng]
      
      return render :json => {
            :restaurants => Restaurant.by_distance(params[:lat], params[:lng]).as_json
      }
      
    # else
      # return render :json => {
      #       :error => "lat or/and lng not specified"
      # }
    # end
  end
  
  
end
