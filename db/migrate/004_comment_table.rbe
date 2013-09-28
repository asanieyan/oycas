class CommentTable < ActiveRecord::Migration
  def self.up
      drop_table :oycas_blog_comments rescue
      create_table "comments", :force => true do |t|
        t.column "commentable_id", :integer, :limit => 10, :default => 0, :null => false
        t.column "commentable_type",:string,:limit=>100,:null=>false
        t.column "student_id", :integer, :limit => 10, :default => 0, :null => false
        t.column "comment",:string, :limit => 500, :default => "", :null => false
        t.column "created_on", :datetime, :null => false        
      end   
#      create_table "articles", :force => true do |t|
#        t.column "headline", :string,:limit =>100, :default => "", :null => false
#        t.column "graphic",:string,:limit =>100
#        t.column "text", :text,:null => false
#        t.column "created_on", :datetime, :null => false        
#      end           
  end

  def self.down
    drop_table :comments
#    drop_table :artciles
  end
end
