# This migration comes from yelp (originally 20120706100418)
class HighlightParsed < ActiveRecord::Migration
  def change
    add_column :yelp_highlight_dishes, :parsed, :boolean, :default => false
  end
end
