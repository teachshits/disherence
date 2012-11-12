require 'carrierwave/orm/activerecord'

class Review < ActiveRecord::Base
  attr_accessible :dish_id, :user_id, :opinion, :comment, :remote_photo, :photo, :local_photo, :remote_photo_source_url, :remote_photo_source_type, :comment_source_type, :comment_source_url
  
  belongs_to :dish
  belongs_to :user
  
  validates :user_id, :uniqueness => {:scope => [:dish_id, :opinion]}

  mount_uploader :local_photo, LocalPhotoUploader

  scope :with_photos, where('reviews.remote_photo IS NOT NULL')

  after_create do |record|
    if record.opinion
      record.dish.update_attributes(:likes => record.dish.likes + 1)
    else
      record.dish.update_attributes(:dislikes => record.dish.dislikes + 1)
    end
  end

  after_destroy do |record|
    if record.opinion
      record.dish.update_attributes(:likes => record.dish.likes - 1)
    else
      record.dish.update_attributes(:dislikes => record.dish.dislikes - 1)
    end
  end
  
  # def as_json(options={})
  #   super(:only => [:id, :opinion, :comment, :remote_photo], :include => [:user => {:only => [:name, :id, :remote_photo]}], :include => [:dish => {:only => [:name, :id], :include => [:restaurant => {:only => [:name, :address, :id]}]}])
  # end
  
  # def opinion
  #   self[:opinion] || 3
  # end
  
  def photo
    if self[:local_photo].blank? 
      if !self[:remote_photo].blank?
        self[:remote_photo]
      elsif review = Review.where("dish_id = ? AND local_photo IS NOT NULL", self[:dish_id]).first
        review.local_photo
      elsif review = Review.where("dish_id = ? AND remote_photo IS NOT NULL", self[:dish_id]).first
        review.remote_photo
      else
        "http://demo.disherence.com/images/no-dish-photo-profile.png"
      end
    else
      self[:local_photo]
    end
  end
  
  def comment_source_type
    'http://demo.disherence.com/images/yelp_src.png' if self[:comment_source_type] == "yelp"
  end
  
  def remote_photo_source_type
    'http://demo.disherence.com/images/yelp_src.png' if self[:comment_source_type] == "yelp"
  end
  
  def comment
    self[:comment] || ""
  end 
  
  def user_photo
    self[:user_photo] || ""
  end
  
  def self.dish
    self.dish.select([:id, :name, :remote_photo])
  end
  
  def agree?(user_id)
    if review_user_choise = Review.find_by_dish_id_and_user_id(self.dish_id, self.user_id)
      if current_user_choise = Review.find_by_dish_id_and_user_id(self.dish_id, user_id)
        review_user_choise.opinion == current_user_choise.opinion ? 1 : 0
      end
    end
  end
  
  def count_agree
    if user_review = Review.find_by_dish_id_and_user_id(dish_id,user_id)
      user_review.opinion == true ? user_review.dish.likes - 1 : user_review.dish.dislikes - 1
    end
  end
  
  def count_disagree
    if user_review = Review.find_by_dish_id_and_user_id(dish_id,user_id)
      user_review.opinion == false ? user_review.dish.likes : user_review.dish.dislikes
    end
  end
  
  
  def self.awesome(dish_id, user_id, local_photo = nil)
    if rd = find_by_dish_id_and_user_id(dish_id,user_id)
      rd.destroy
    end
    
    loves_fb_action(User.find_by_id(user_id), dish_id)
    create(:dish_id => dish_id, :user_id => user_id, :opinion => true, :local_photo => local_photo)
    
    unless local_photo.nil?
      dish = Dish.find_by_id(dish_id)
      dish.update_attributes(:photos => dish.photos + 1)
    end
    
  end
  
  def self.awful(dish_id, user_id, photo = nil)
    if rd = find_by_dish_id_and_user_id(dish_id,user_id)
      rd.destroy
    end
    hate_fb_action(User.find_by_id(user_id), dish_id)
    create(:dish_id => dish_id, :user_id => user_id, :opinion => false, :local_photo => photo)
  end
  
  def self.loves_fb_action(user, dish_id)
    domain = 'http://demo.disherence.com'
    
    activity_url = "https://graph.facebook.com/me/disherence:love"
    activity_url += "?access_token=#{user.fb_access_token}"
    activity_url += "&dish="+ CGI.escape("#{domain}/reviews/show/#{dish_id}").gsub("+", "%20")
    
    system "rake net:post URL='#{activity_url}' &"    
    # activity = HTTParty.post(activity_url)
  end
  
  def self.hate_fb_action(user, dish_id)
    domain = 'http://demo.disherence.com'
    
    activity_url = "https://graph.facebook.com/me/disherence:hate"
    activity_url += "?access_token=#{user.fb_access_token}"
    activity_url += "&dish="+ CGI.escape("#{domain}/reviews/show/#{dish_id}").gsub("+", "%20")

    system "rake net:post URL='#{activity_url}' &"
    # activity = HTTParty.post(activity_url)
  end
  
  
  def self.agree(review_id, user_id)
    if r = Review.find_by_id(review_id)
      if user_id != r.user_id
        r.opinion == true ? awesome(r.dish_id, user_id) : awful(r.dish_id, user_id)
      end
    end
  end
  
  def self.disagree(review_id, user_id)
    if r = Review.find_by_id(review_id)
      if user_id != r.user_id
        r.opinion == false ? awesome(r.dish_id, user_id) : awful(r.dish_id, user_id)
      end
    end
  end
end
