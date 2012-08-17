require 'carrierwave/orm/activerecord'

class Review < ActiveRecord::Base
  attr_accessible :dish_id, :user_id, :opinion, :comment, :remote_photo
  
  belongs_to :dish
  belongs_to :user
  
  validates :user_id, :uniqueness => {:scope => [:dish_id, :opinion]}

  mount_uploader :photo, ReviewPhotoUploader

  scope :with_photos, where('remote_photo IS NOT NULL')

  # after_create do |record|
  #   if record.opinion
  #     record.dish.update_attributes(:likes => record.dish.likes + 1)
  #   else
  #     record.dish.update_attributes(:dislikes => record.dish.dislikes + 1)
  #   end
  # end

  after_destroy do |record|
    if record.opinion
      record.dish.update_attributes(:likes => record.dish.likes - 1)
    else
      record.dish.update_attributes(:dislikes => record.dish.dislikes - 1)
    end
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
  
  
  def self.awesome(dish_id, user_id)
    if rd = find_by_dish_id_and_user_id(dish_id,user_id)
      rd.destroy
    end
    self.create(:dish_id => dish_id, :user_id => user_id, :opinion => true)
  end
  
  def self.awful(dish_id, user_id)
    if rd = find_by_dish_id_and_user_id(dish_id,user_id)
      rd.destroy
    end
    self.create(:dish_id => dish_id, :user_id => user_id, :opinion => false)
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
