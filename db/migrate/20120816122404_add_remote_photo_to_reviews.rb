class AddRemotePhotoToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :remote_photo, :string
  end
end
