# This migration comes from yelp (originally 20120706095547)
class HighlightModify < ActiveRecord::Migration
  def change
    add_column :yelp_highlight_dishes, :sentence_review_id, :string
    add_column :yelp_highlight_dishes, :ylp_uri, :string
  end
end
