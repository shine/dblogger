class CreateLoggedEvents < ActiveRecord::Migration
  def self.up
    create_table :logged_events do |t|
      t.column :environment, :string, :null => false, :limit => 30
      t.column :level, :string, :null => false, :limit => 10
      t.column :message, :text, :null => false
      t.column :block_text, :text, :null => false
      t.column :ip, :string, :length => 20
      t.column :controller, :string, :length => 100
      t.column :action, :string, :length => 100
      t.column :request_type, :string, :length => 10
      t.column :processing_time, :integer, :length => 10
      t.column :response_code, :integer, :length => 4
      t.column :response_status, :string, :length => 50
      t.column :request_url, :string, :length => 200
      t.column :content_type, :string, :limit => 100
      t.column :request_id, :string

      t.timestamps
    end
  end

  def self.down
    drop_table :logged_events
  end
end
