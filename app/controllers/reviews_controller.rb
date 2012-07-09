class ReviewsController < ApplicationController
  
  def index
    @facebook_app_id = Rails.application.config.facebook_app_id
    @redirect_uri = Rails.application.config.redirect_uri
    
    @reviews = Review.where('photo IS NOT NULL').order('id DESC').limit(100)
    @reviews = @reviews.where('user_id != ?', session[:user].id) unless session[:user].nil?
  end
  
  def awesome
    if dish_id = params[:id]
      if user = session[:user]
        Review.awesome(dish_id,user.id)
        return render :text => 1
      else
        return render :text => "'#{Rails.application.config.fb_auth_url}'"
      end
    end
  end
  
  def awful
    if dish_id = params[:id]
      if user = session[:user]
        Review.awful(dish_id,user.id)
        return render :text => 1
      else
        return render :text => "'#{Rails.application.config.fb_auth_url}'"
      end
    end
  end
  
  def agree
    if review_id = params[:id]
      if user = session[:user]
        r = Review.agree(review_id,user.id)
        
        disagree = r.opinion == true ? r.dish.dislikes : r.dish.likes
        agree = r.opinion == true ? r.dish.likes - 1 : r.dish.dislikes - 1
        return render :text => "1,#{r.dish.likes},#{r.dish.likes + r.dish.dislikes},#{r.dish.photos},#{agree},#{disagree},#{r.dish.dislikes}"
      else
        return render :text => "'#{Rails.application.config.fb_auth_url}'"
      end
    end
  end
  
  def disagree
    if review_id = params[:id]
      if user = session[:user]
        r = Review.disagree(review_id,user.id)
        disagree = r.opinion == true ? r.dish.dislikes : r.dish.likes
        agree = r.opinion == true ? r.dish.likes - 1 : r.dish.dislikes - 1
        return render :text => "1,#{r.dish.likes},#{r.dish.likes + r.dish.dislikes},#{r.dish.photos},#{agree},#{disagree},#{r.dish.dislikes}"
      else
        return render :text => "'#{Rails.application.config.fb_auth_url}'"
      end
    end
  end
  
  def destroy
    if dish_id = params[:id]
      if user = session[:user]
        if rd = Review.find_by_dish_id_and_user_id(dish_id,user.id)
          if rw = Review.find_by_id(params[:review_id])
            
            stats = [1]
            stats.push(rd.dish.likes)
            stats.push(rd.dish.likes + rd.dish.dislikes - 1)
            stats.push(rd.dish.photos)
            stats.push(rw.count_agree)
            stats.push(rw.count_disagree)
            stats.push(rd.dish.dislikes)
            
            rw.agree?(user.id) == 1 ? stats[4] -= 1 : stats[5] -= 1
 
            rd.destroy
            return render :text => stats.join(',')
          end
        end
      end
    end
  end
  
  
end

