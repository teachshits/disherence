# This migration comes from yelp (originally 20120706115434)
class HighlightRemoveYelpUri < ActiveRecord::Migration
  def change
    remove_column :yelp_highlight_dishes, :ylp_uri
  end
end
