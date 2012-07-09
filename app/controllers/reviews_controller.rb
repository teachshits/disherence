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
        r = Review.awesome(dish_id,user.id)        
        
        stats = [1]
        stats.push(r.dish.likes)
        stats.push(r.dish.dislikes)
        stats.push((r.dish.likes * 100)/r.dish.restaurant.dishes.sum(:likes))
        
        return render :text => stats.join(',')
      else
        return render :text => "'#{Rails.application.config.fb_auth_url}'"
      end
    end
  end
  
  def awful
    if dish_id = params[:id]
      if user = session[:user]
        r = Review.awful(dish_id,user.id)
        
        stats = [1]
        stats.push(r.dish.likes)
        stats.push(r.dish.dislikes)
        stats.push((r.dish.likes * 100)/r.dish.restaurant.dishes.sum(:likes))
        
        return render :text => stats.join(',')
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
          
          stats = [1]
          if rw = Review.find_by_id(params[:review_id])
            
            stats.push(rd.dish.likes)
            stats.push(rd.dish.likes + rd.dish.dislikes - 1)
            stats.push(rd.dish.photos)
            stats.push(rw.count_agree)
            stats.push(rw.count_disagree)
            stats.push(rd.dish.dislikes)

            rw.agree?(user.id) == 1 ? stats[4] -= 1 : stats[5] -= 1
          else
            stats.push(rd.dish.likes)
            stats.push(rd.dish.dislikes)
            
            if rd.opinion == true
              stats.push(((rd.dish.likes - 1) * 100)/(rd.dish.restaurant.dishes.sum(:likes) - 1))
              stats[1] -= 1
            else
              stats.push((rd.dish.likes * 100)/rd.dish.restaurant.dishes.sum(:likes))
              stats[2] -= 1
            end

          end          
          
          rd.destroy
          return render :text => stats.join(',')
          
        end
      end
      
    end
  end
  
  
end

