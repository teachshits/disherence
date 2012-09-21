require 'carrierwave/orm/activerecord'

class User < ActiveRecord::Base
  attr_accessible :fb_access_token, :fb_valid_to, :email, :name, :facebook_id, :gender, :current_city, :yelp_profile_id, :remote_photo_url, :remote_photo, :token
  has_many :reviews
  
  validates_uniqueness_of :email, :if => lambda { !self.email.nil? }
  validates_uniqueness_of :fb_access_token, :if => lambda { self.email.nil? && !self.fb_access_token.nil? }

  # mount_uploader :photo, ProfilePhotoUploader
  
  require 'digest/md5'
  require 'cgi' 
  
  def self.share_on_facebook(user_token, restaurant_id)
    
    if user = find_by_token(user_token)
      if restaurant = Restaurant.find_by_id(restaurant_id)
        
        restaurant_name = CGI.escape(restaurant.name).gsub("+", "%20")
        
        fb_share_url =  "https://graph.facebook.com/#{user.facebook_id}/feed"
        fb_share_url += "?access_token=#{user.fb_access_token}"
        
        fb_share_url += "&link=" + CGI.escape("http://demo.disherence.com/restaurants/show/#{restaurant_id}").gsub("+", "%20")
        fb_share_url += "&message= message#{restaurant_name}"
        fb_share_url += "&description=description#{restaurant_name}"
        fb_share_url += "&name=name#{restaurant_name}"
        fb_share_url += "&caption=caption#{restaurant_name}"
        # fb_share_url += "&place=#{restaurant}" + CGI.escape(restaurant.name).gsub("+", "%20")
        
        if dish = Dish.where("restaurant_id = ? AND photos > 0",restaurant_id).order("likes DESC").first
          photo = dish.reviews.where("remote_photo IS NOT NULL").first.remote_photo
          fb_share_url += "&picture=" + CGI.escape(photo).gsub("+", "%20")
        end

        response = HTTParty.post(fb_share_url)
        
      end
    end
    
  end
  
  def as_json(options={})
    super(:only => [:token])
  end

  def photo
    if !self[:facebook_id].blank?
      "http://graph.facebook.com/#{facebook_id}/picture?type=large"
    else  
      self[:remote_photo].blank? ? '/images/user_no_photo.png' : self[:remote_photo]
    end
  end  
  
  def self.authenticate_by_facebook(access_token_data)
    user_data = get_facebook_user_data(access_token_data[:fb_access_token])
    
    if user_data && user = User.find_by_facebook_id(user_data[:facebook_id]) 
      user
    else
      data = access_token_data.merge(user_data)
      user = create(data)
    end    
    
    user.update_attributes(:token => Digest::MD5.hexdigest(user.created_at.to_s).to_s) if user.token.blank?
    user
  end
  
  def self.create_from_facebook(code)
    access_token_data = get_facebook_access_token_data(code)
    authenticate_by_facebook(access_token_data)
  end
  
  def self.get_facebook_access_token_data(code)
    
    fb_access_token_url =  'https://graph.facebook.com/oauth/access_token'      
    fb_access_token_url += "?client_id=#{Rails.application.config.facebook_app_id}"
    fb_access_token_url += "&redirect_uri=#{Rails.application.config.redirect_uri}"
    fb_access_token_url += "&client_secret=#{Rails.application.config.client_secret}"
    fb_access_token_url += "&code=#{code}"
    
    response = HTTParty.get(fb_access_token_url).body
    data = {}
    
    response.split('&').each do |p|
      d = p.split('=')
      if d[0] == 'access_token'
        data[:fb_access_token] = d[1] 
      elsif d[0] == 'expires'
        data[:fb_valid_to] = d[1]
      end
    end
    data
  end
  
  def self.get_facebook_user_data(access_token)
    url = "https://graph.facebook.com/me?access_token=#{access_token}"
    response = JSON.parse(HTTParty.get(url).body)
    
    data = {
      :email => response['email'],
      :name => response['name'],
      :facebook_id => response['id'],
      :gender => response['gender'],
      :current_city => response['location'] ? response['location']['name'] : nil
    }
  end
  
  def self.authenticate_by_twitter(oauth_token, oauth_token_secret, email = nil)
    begin
      client = Twitter::Client.new(:oauth_token => oauth_token, :oauth_token_secret => oauth_token_secret)
      if user = User.find_by_twitter_id(client.user.id)
        user.oauth_token = oauth_token
        user.oauth_token_secret = oauth_token_secret
        user.save
      else
        user = create_user_from_twitter(client, email)
      end
      token = Session.get_token(user)
    rescue
      nil
    end
    {:name => user.name, :fb_access_token =>user.fb_access_token, :fb_valid_to => user.fb_valid_to.to_i, :oauth_token => user.oauth_token, :oauth_token_secret => user.oauth_token_secret, :token => token, :user_id => user.id, :photo => user.user_photo, :facebook_id => user.facebook_id ||= 0, :twitter_id => user.twitter_id ||= 0} unless token.nil?
  end
  
  def self.create_user_from_twitter(client, email = nil)
    user = User.create({
      :name => client.user.name,
      :email => email,  
      :twitter_id => client.user.id,
      :remote_photo_url => client.profile_image,
      :oauth_token => client.oauth_token,
      :oauth_token_secret => client.oauth_token_secret
    })
    # UserPreference.create({:user_id => user.id})
    # 
    # get_twitter_friends(client, user)
    # get_twitter_followers(client, user)
    # follow_dishfm_user(user.id)
    
    user
  end
  
end
