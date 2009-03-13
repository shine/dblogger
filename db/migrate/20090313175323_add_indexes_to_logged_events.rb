class AddIndexesToLoggedEvents < ActiveRecord::Migration
  def self.up
    add_index :logged_events, :environment
    add_index :logged_events, :level
    add_index :logged_events, :ip
    add_index :logged_events, :controller
    add_index :logged_events, :action
    add_index :logged_events, :created_at
  end

  def self.down
    remove_index :logged_events, :environment
    remove_index :logged_events, :level
    remove_index :logged_events, :ip
    remove_index :logged_events, :controller
    remove_index :logged_events, :action
    remove_index :logged_events, :created_at
  end
end
