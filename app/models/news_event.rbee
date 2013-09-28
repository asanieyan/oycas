class NewsEvent < ActiveRecord::Base
    Note = "note"
    Instructor = "instructor"
    Forum = "forum"
    ClassifiedReply = "post_reply"
    def self.create guid,type,text            
        news = (self.new :context_guid=>guid,:type=>type,:message=>text)
        news.icon_url = "/images/" + case type 
                                         when Note;"shared_notes_news_icon"
                                         when Instructor;"instructor_news_icon" 
                                         when Forum;"forums_news_icon"
                                         when ClassifiedReply;"classified_news_icon"
                                     end + ".gif"
                                     
        news.save
#        p news.save
#        
#        p news.inspect
    end
end
