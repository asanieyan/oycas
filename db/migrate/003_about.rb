class About < ActiveRecord::Migration
  def self.up
#      add_column :students,:online_status, :enum, :limit => ['Online','Appear Offline'],:default=>"Online"
#      Student.reset_column_information
#      Student.find(:all).each do |student|
#        student.update_attribute('online_status',:Online)
#      end
      remove_column :admins,:time_zone
      Admin.reset_column_information
      create_table "oycas_blogs", :force => true do |t|
        t.column "oycas_userid", :integer, :limit => 10,  :null => false
        t.column "subject", :string,:limit =>100, :default => "", :null => false
        t.column "text", :text,:null => false
        t.column "month_id", :string,:limit=>"6"
        t.column "created_on", :datetime, :null => false        
      end      
      create_table "oycas_blog_comments", :force => true do |t|
        t.column "blog_id", :integer, :limit => 10, :default => 0, :null => false
        t.column "student_id", :integer, :limit => 10, :default => 0, :null => false
        t.column "comment",:string, :limit => 500, :default => "", :null => false
        t.column "created_on", :datetime, :null => false        
      end      
  end
  def self.down
      drop_table :oycas_blogs
      drop_table :oycas_blog_comments
#      add_column :admins,:title
  end
end
