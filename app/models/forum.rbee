class Forum < ActiveRecord::Base
  before_create :set_last_post
  belongs_to :creator, :class_name=>'Student',:foreign_key=>'creator_id'
  belongs_to :last_poster,:class_name=>'Student',:foreign_key=>'last_poster_id' 
  has_many :posts,:class_name=>'ForumThread',:foreign_key=>'topic_id',:order=>'created_on ASC',:dependent=>:delete_all  
  
  escape_once_and_truncate 'topic' 
  def last_post= post
       self.last_post_time = post.created_on
       self.last_poster_id = post.poster_id
       self.last_post_id = post.id
       self.save
  end
  def validate
      if (topic || "").size == 0
          errors.add(:topic,'Please enter a discussion topic.')        
      end
    
  end
  def set_last_post
      #self.num_posts = 1
  end

end
