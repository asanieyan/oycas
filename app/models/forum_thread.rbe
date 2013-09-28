class ForumThread < ActiveRecord::Base

    belongs_to :poster, :class_name=>'Student',:foreign_key=>'poster_id'
    belongs_to :discussion,:class_name=>'Forum',:foreign_key=>'topic_id'
    belongs_to :thread,:class_name=>'ForumThread',:foreign_key=>'thread_replyee_id'
        
    
    escape_once_and_truncate 'subject'
    sanitize_html 'message'
    
    def before_destroy
        if self.discussion.last_post_id == self.id                    
            post = ForumThread.find(:first,:conditions=>"id != #{id} AND topic_id = #{discussion.id}",
                                :order=>"created_on DESC")
            self.discussion.last_post = post
        end
        self.class.update_all("thread_replyee_id = NULL","thread_replyee_id = #{self.id}")
    end

    def validate   
        if not ActiveRecordTextHelper::strip_tags(self.message).match(/\S/)
          errors.add(:body,'Please enter a post.')
          return false
        elsif message.size >= 65535 #total size of a text field
          errors.add(:body,%(Your post is too long. 
                              Please revise your post so it is
                               less than 65535 characters.
                    ))
                    
          return false
        end
    end 
end
