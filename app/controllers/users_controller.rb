class UsersController < ApplicationController
  
  def auth_callback
    if params[:id] == 'facebook'
      
      if code = params[:code]
        if session[:user] = User.create_from_facebook(params[:code])
          redirect_to '/'
        end
      end
    elsif params[:oauth_token] && params[:oauth_verifier]
      
      consumer_key = "XQlhrLVWUJK7q1AK9uTeQ"
      consumer_secret = "M2iDOlkxW8Y7430Q6HgFquY1haZnaEqIVrFhyE0XIo"

      consumer = OAuth::Consumer.new(consumer_key, consumer_secret, :site => "http://api.twitter.com", :scheme => :header)
     
      # Re-create the request token
      request_token = OAuth::RequestToken.new(consumer, session[:request_token], session[:request_secret])

      # Convert the request token to an access token using the verifier Twitter gave us
      access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])            
      
      session[:oauth_token] = access_token.token
      session[:oauth_secret] = access_token.secret
      
      
      session[:user] = User.authenticate_by_twitter(access_token.token, access_token.secret)

      # Hand off to our app, which actually uses the API with the above token and secret
      redirect_to '/'
        
    end
  end  
  
  def logout
    session[:user] = nil
    return render :json => {:result => 1}
  end
  
  def profile
    if session[:user]
      @reviews = Review.where("user_id = ?", session[:user].id)
    end
  end
  
end
