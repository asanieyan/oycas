module News
    def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
    end 
    module ClassMethods
        def add_news_for context,*guids
              @news_context = context
              @guid_set = guids #array of variable that hold guids 
              #before_filter :set_news, :only=>%w(show_notes)
        end
    end
    module InstanceMethods
      private
        def r text
            render_to_string :inline=>text
        end
        def create_news_for_classified_post_reply poster,post
            @poster = poster
            @post = post                       
            NewsEvent.create(poster.guid,NewsEvent::ClassifiedReply,r(<<-eof                
                <%=link_to_student @me%> replied to your ad post: <br>
                <span class='dark-bold-gray'><%=link_to truncate(@post.title,30),"/classifieds/network/#{@post.network.name}/show/#{@post.id}"%></span>
            eof
            ))
        end
        def create_news_for_class_teacher(context,old_teacher,new_teacher)           
          if old_teacher
           msg = r(<<-eof
               <%=link_to_student(@me)%> changed the class instructor from #{old_teacher.name1} to #{new_teacher.name1}.           
           eof
           )          
          else
           msg = r(<<-eof
               <%=link_to_student(@me)%> set the class instructor to #{new_teacher.name1}.          
           eof
           )          
          end
          NewsEvent.create(context.guid,NewsEvent::Instructor,msg)
            
        end        
      public
       def guids_for_news       
             if not @news_guids
              @news_guids = []
              @news_context = eval(self.class.instance_variable_get("@news_context"),binding)
              self.class.instance_variable_get("@guid_set").each do |guid|
                  @news_guids << eval(guid,binding)
              end
             end
             return @news_guids
             
       end
       def show_news             
             @news = NewsEvent.find(:all,:order=>"created_on DESC",:conditions=>"context_guid IN (#{guids_for_news.join(', ')})")
             render_p 'news/show_news'
       end
    end
end