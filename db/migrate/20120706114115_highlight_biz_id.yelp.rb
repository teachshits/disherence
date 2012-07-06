# This migration comes from yelp (originally 20120706114022)
class HighlightBizId < ActiveRecord::Migration
  def change
    add_column :yelp_highlight_dishes, :biz_id, :string
  end
end
