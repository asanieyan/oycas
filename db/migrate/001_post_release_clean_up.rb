class PostReleaseCleanUp < ActiveRecord::Migration
  def self.up
    change_column :forum_threads, :message, :text
    change_column :intranet_messages, :body, :text
    change_column :classified_posts, :description, :text
    ForumThread.reset_column_information    
    IntranetMessage.reset_column_information
    ClassifiedPost.reset_column_information
    drop_table :school_forum_records rescue p ":school_forum_records doesn't exists"
    drop_table :klass_forum_records rescue p ":klass_forum_records doesn't exists"
    drop_table :project_forum_records rescue p ":project_forum_records doesn't exists"
    drop_table :file_mimes rescue p ":file_mimes doesn't exists"
    drop_table :document_files rescue p ":document_files doesn't exists"
  end

  def self.down
#    change_column :forum_threads, :message, :string, :limit => 3000
#    change_column :intranet_messages,"body", :string, :limit => 5000    
     change_column :classified_posts, :description, :binary
     ClassifiedPost.reset_column_information
#    ForumThread.reset_column_information    

  end
end
