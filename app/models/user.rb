require 'carrierwave/orm/activerecord'

class User < ActiveRecord::Base
  attr_accessible :fb_access_token, :fb_valid_to, :email, :name, :facebook_id, :gender, :current_city, :yelp_profile_id, :remote_photo_url
  has_many :reviews
  
  validates_uniqueness_of :email, :if => lambda { !self.email.nil? }
  validates_uniqueness_of :fb_access_token, :if => lambda { self.email.nil? && !self.fb_access_token.nil? }

  mount_uploader :photo, ProfilePhotoUploader

  def photo
    if !self[:photo].blank?
      self.photo.thumb.url
    else
     "http://graph.facebook.com/#{facebook_id}/picture?type=large" unless facebook_id.blank?
    end
  end
  
  
  def self.create_from_facebook(code)
    access_token_data = get_facebook_access_token_data(code)
    user_data = get_facebook_user_data(access_token_data[:fb_access_token])

    data = access_token_data.merge(user_data)
    create(data)
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
  
end
