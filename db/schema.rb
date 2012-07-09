# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120707153646) do

  create_table "dishes", :force => true do |t|
    t.integer  "restaurant_id"
    t.string   "name"
    t.integer  "photos",        :default => 0, :null => false
    t.integer  "likes",         :default => 0
    t.integer  "dislikes",      :default => 0
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  create_table "restaurants", :force => true do |t|
    t.string   "name"
    t.string   "address"
    t.string   "phone"
    t.string   "cuisine"
    t.string   "bill"
    t.integer  "yelp_reviews_count"
    t.integer  "lat",                :limit => 8
    t.integer  "lng",                :limit => 8
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "reviews", :force => true do |t|
    t.integer  "user_id"
    t.integer  "dish_id"
    t.string   "photo"
    t.boolean  "opinion"
    t.string   "comment"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "crypted_password"
    t.string   "salt"
    t.string   "remember_me_token"
    t.string   "photo"
    t.string   "name"
    t.integer  "facebook_id",                  :limit => 8
    t.string   "twitter_id"
    t.string   "vkontakte_id"
    t.string   "gender"
    t.string   "current_city"
    t.string   "fb_access_token"
    t.string   "oauth_token_secret"
    t.string   "oauth_token"
    t.datetime "fb_valid_to"
    t.datetime "remember_me_token_expires_at"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "yelp_highlight_dishes", :force => true do |t|
    t.integer  "restaraunt_id"
    t.string   "quote"
    t.integer  "reviews_count"
    t.string   "dish_name"
    t.string   "dish_photo"
    t.string   "profile_id"
    t.string   "profile_name"
    t.string   "profile_photo"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "sentence_review_id"
    t.boolean  "parsed",             :default => false
    t.string   "dish_photo_url"
    t.string   "profile_photo_url"
    t.string   "biz_id"
  end

  create_table "yelp_restaurants", :force => true do |t|
    t.string   "name"
    t.string   "ylp_uri"
    t.string   "lat"
    t.string   "lng"
    t.string   "rating"
    t.string   "review_count"
    t.string   "category"
    t.string   "address"
    t.string   "phone"
    t.string   "web"
    t.string   "transit"
    t.string   "hours"
    t.string   "parking"
    t.string   "cc"
    t.string   "price"
    t.string   "attire"
    t.string   "groups"
    t.string   "kids"
    t.string   "reservation"
    t.string   "delivery"
    t.string   "takeout"
    t.string   "table_service"
    t.string   "outdoor_seating"
    t.string   "wifi"
    t.string   "meal"
    t.string   "alcohol"
    t.string   "noise"
    t.string   "ambience"
    t.string   "tv"
    t.string   "caters"
    t.string   "wheelchair_accessible"
    t.string   "fsq_id"
    t.string   "fsq_name"
    t.string   "fsq_address"
    t.string   "fsq_lat"
    t.string   "fsq_lng"
    t.string   "fsq_checkins_count"
    t.string   "fsq_users_count"
    t.string   "fsq_tip_count"
    t.string   "restaurant_categories"
    t.string   "city"
    t.boolean  "has_menu",              :default => false
    t.integer  "db_status"
    t.integer  "our_network_id"
    t.boolean  "menu_copied"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "yelp_restaurants", ["city"], :name => "index_yelp_restaurants_on_city"
  add_index "yelp_restaurants", ["fsq_id"], :name => "index_yelp_restaurants_on_fsq_id"
  add_index "yelp_restaurants", ["has_menu"], :name => "index_yelp_restaurants_on_has_menu"
  add_index "yelp_restaurants", ["name"], :name => "index_yelp_restaurants_on_name"
  add_index "yelp_restaurants", ["ylp_uri"], :name => "index_yelp_restaurants_on_ylp_uri", :unique => true

end
