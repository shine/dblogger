# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090313175323) do

  create_table "logged_events", :force => true do |t|
    t.string   "environment",     :limit => 30,  :null => false
    t.string   "level",           :limit => 10,  :null => false
    t.text     "message",                        :null => false
    t.text     "block_text",                     :null => false
    t.string   "ip"
    t.string   "controller"
    t.string   "action"
    t.string   "request_type"
    t.integer  "processing_time"
    t.integer  "response_code"
    t.string   "response_status"
    t.string   "request_url"
    t.string   "content_type",    :limit => 100
    t.string   "request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "logged_events", ["action"], :name => "index_logged_events_on_action"
  add_index "logged_events", ["controller"], :name => "index_logged_events_on_controller"
  add_index "logged_events", ["created_at"], :name => "index_logged_events_on_created_at"
  add_index "logged_events", ["environment"], :name => "index_logged_events_on_environment"
  add_index "logged_events", ["ip"], :name => "index_logged_events_on_ip"
  add_index "logged_events", ["level"], :name => "index_logged_events_on_level"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
