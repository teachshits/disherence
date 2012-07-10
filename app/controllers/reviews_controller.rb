class ReviewsController < ApplicationController
  
  def index
          
    @facebook_app_id = Rails.application.config.facebook_app_id
    @redirect_uri = Rails.application.config.redirect_uri
    
    @reviews = Review.with_photos.order('RAND()').limit(10)
    @reviews = @reviews.where('user_id != ?', session[:user].id) unless session[:user].nil?
    @reviews.page params[:page]
    
    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.xml  { render :xml => @reviews }
    end
    
  end
  
  def awesome
    if dish_id = params[:id]
      if user = session[:user]
        r = Review.awesome(dish_id,user.id)        
        
        likes = r.dish.likes
        dislikes = r.dish.dislikes
        rating = (r.dish.likes * 100)/r.dish.restaurant.dishes.sum(:likes)
        
        return render :json => {:result => 1, :likes => likes, :dislikes => dislikes, :rating => rating}
      else
        return render :json => {"result" => 0, "url" => Rails.application.config.fb_auth_url}
      end
    end
  end
  
  def awful
    if dish_id = params[:id]
      if user = session[:user]
        r = Review.awful(dish_id,user.id)
        
        likes = r.dish.likes
        dislikes = r.dish.dislikes
        rating = (r.dish.likes * 100)/r.dish.restaurant.dishes.sum(:likes)
        
        return render :json => {"result" => 1, "likes" => likes, :dislikes => dislikes, :rating => rating}
      else
        return render :json => {"result" => 0, "url" => Rails.application.config.fb_auth_url}
      end
    end
  end
  
  def agree
    if review_id = params[:id]
      if user = session[:user]
        r = Review.agree(review_id,user.id)
        
        disagree = r.opinion == true ? r.dish.dislikes : r.dish.likes
        agree = r.opinion == true ? r.dish.likes - 1 : r.dish.dislikes - 1
        
        return render :json => {
          :result => 1,
          :likes => r.dish.likes, 
          :dislikes => r.dish.dislikes,
          :users => r.dish.likes + r.dish.dislikes,
          :photos => r.dish.photos,
          :agree => agree,
          :disagree => disagree,
        }
      else
        return render :json => {"result" => 0, "url" => Rails.application.config.fb_auth_url}
      end
    end
  end
  
  def disagree
    if review_id = params[:id]
      if user = session[:user]
        r = Review.disagree(review_id,user.id)
        disagree = r.opinion == true ? r.dish.dislikes : r.dish.likes
        agree = r.opinion == true ? r.dish.likes - 1 : r.dish.dislikes - 1
        
        return render :json => {
          :result => 1,
          :likes => r.dish.likes, 
          :dislikes => r.dish.dislikes,
          :users => r.dish.likes + r.dish.dislikes,
          :photos => r.dish.photos,
          :agree => agree,
          :disagree => disagree,
        }
        
      else
        return render :json => {"result" => 0, "url" => Rails.application.config.fb_auth_url}
      end
      
    end
  end
  
  def destroy
    if dish_id = params[:id]
      if user = session[:user]
        
        if rd = Review.find_by_dish_id_and_user_id(dish_id,user.id)
          
          if rw = Review.find_by_id(params[:review_id])
            
            likes = rd.dish.likes
            dislikes = rd.dish.dislikes
            users = rd.dish.likes + rd.dish.dislikes - 1
            photos = rd.dish.photos
            agree = rw.count_agree
            disagree = rw.count_disagree

            rw.agree?(user.id) == 1 ? agree -= 1 : disagree -= 1
            rd.opinion == true ? likes -= 1 : dislikes -= 1
          else
            likes = rd.dish.likes
            dislikes = rd.dish.dislikes
            
            if rd.opinion == true
              rating = ((likes - 1) * 100)/(rd.dish.restaurant.dishes.sum(:likes) - 1)
              likes -= 1
            else
              rating = (likes * 100)/rd.dish.restaurant.dishes.sum(:likes)
              dislikes -= 1
            end

          end
          rd.destroy
          
          return render :json => {
            :result => 1,
            :likes => likes, 
            :dislikes => dislikes,
            :users => users,
            :photos => photos,
            :agree => agree,
            :disagree => disagree,
            :rating => rating || nil
          }
          
        end
      end
      
    end
  end
  
end