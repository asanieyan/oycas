class FacebookAndLat < ActiveRecord::Migration
  def self.up
      add_column :students, :facebook_uid,:integer, :limit => 10
      add_column :students, :last_access_time,:datetime,:after=>'logoff_time'
  end
  def self.down
      remove_column :students, :facebook_uid
      remove_column :students, :last_access_time
  end
end
