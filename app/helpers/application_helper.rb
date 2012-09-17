module ApplicationHelper
  
  def user_picture
    if session[:user]
      raw "<div class=\"user_img\" style=\"background: url('#{session[:user].photo}') left center\"></div>"
    else
      raw session
    end
  end
  
  
end
