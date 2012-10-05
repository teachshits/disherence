class AddLocalPhotoToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :local_photo, :string
  end
end
