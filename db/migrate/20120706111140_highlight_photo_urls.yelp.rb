# This migration comes from yelp (originally 20120706111049)
class HighlightPhotoUrls < ActiveRecord::Migration
  def change
    add_column :yelp_highlight_dishes, :dish_photo_url, :string
    add_column :yelp_highlight_dishes, :profile_photo_url, :string
  end
end
