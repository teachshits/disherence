class AddRemotePhotoSourceInfoToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :remote_photo_source_url, :string
    add_column :reviews, :remote_photo_source_type, :string
    add_column :reviews, :comment_source_url, :string
    add_column :reviews, :comment_source_type, :string
  end
end
