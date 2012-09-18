class UsersController < ApplicationController
  
  def auth_callback
    if params[:id] == 'facebook'
      
      if code = params[:code]
        if session[:user] = User.create_from_facebook(params[:code])
          redirect_to '/'
        end
      end
      
    end
  end  
  
  def logout
    session[:user] = nil
    return render :json => {:result => 1}
  end
  
  
  
end
