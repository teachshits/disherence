module ApplicationHelper
  
  def user_picture
    if session[:user]
      raw "<div class=\"user_img_profile\" style=\"background-image: url('#{session[:user].photo}')\"></div>"
    end
  end
  
  
end
