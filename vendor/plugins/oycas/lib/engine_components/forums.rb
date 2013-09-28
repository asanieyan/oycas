module Forums
    def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
                              
    end     
    module ClassMethods 

      def add_forum_methods context,name=nil   
        before_filter :can_post_to_forum?,:only=>%w(reply_to_topic reply_post new_forum_topic)   
        @forum_context = context        
      end
      def context binding
        eval(@forum_context,binding)
      end 
           
    end
    module InstanceMethods
      private
      def forum_owner
          self.class.context binding
      end
      def get_discussion id
          Forum.find(:first,:conditions=>["context_guid = #{forum_owner.guid} AND id = ?",id]) 
      end
      def new_topic_created forum_topic
       
      end
      def expire_this_forum_fragment
#        expire_fragment(%r{.*/forum_topics.*})
      end
      public    
      def can_post_to_forum?          
          return true unless forum_owner.respond_to? "can_student_post_to_forum?"
          forum_owner.can_student_post_to_forum? @me
      end      
      def reply_to_topic
          begin
            @discussion = get_discussion params[:id] unless @discussion
            if request.post?                            
              @post = ForumThread.new :subject=>params[:topic],:message=>params[:message],
                     :poster_id=>@my.id,:topic_id=>@discussion.id

              if @replied_to_post
                  @post.thread_replyee_id = @replied_to_post.id
              end
              @post.save             

              if @post.errors.empty?
                  @discussion.increment :num_posts
                  @discussion.last_post = @post                          
                  expire_this_forum_fragment
                  redirect_to :action=>'view_topic',:id=>@discussion.id,:page=>'last',:anchor=>@post.id
              else                               
                 r_msg @post.errors         
                 redirect_to :back                
              end       
            return
            end
          rescue Exception=>e
#            p e.message
            redirect_to :action=>'forum_topics'
            return
          end
          render :template=>'forums/new_topic'
      end
      def reply_post
         @replied_to_post =  ForumThread.find(params[:id])
         #make sure the discussion of this post belongs to this context
         #I can reply to any post in a context as long as the post actually belongs to that context
         @discussion = @replied_to_post.discussion
         if @discussion.context_guid != forum_owner.guid
            redirect_to :action=>'forum_topics'
            return
         end
         if request.post?
            reply_to_topic  
            return         
         end
         render :template=>'forums/new_topic'
      end
      def new_forum_topic          
          if request.post?
              forum = Forum.new
              @post = ForumThread.new
              begin 
                  Forum.transaction do 
                        forum = Forum.create :context_guid=>forum_owner.guid,
                                     :topic=>params[:topic],
                                     :creator_id=>@my.id                                        
                        @post = ForumThread.create :subject=>forum.topic,:message=>params[:message],
                                           :poster_id=>@my.id,:topic_id=>forum.id,:is_header=>'y'
    
                        forum.last_post = @post                 
                        raise unless forum.errors.empty? and @post.errors.empty?
                   end                  
              rescue Exception=>e                                                         
                  
                  r_msg(:post_msg=>[forum.errors,@post.errors])                                   

                  redirect_to :back                           
                  return                  
              end    
              expire_this_forum_fragment
              new_topic_created forum
              redirect_to :action=>'forum_topics'                                          
              return
          end
          render :template=>'forums/new_topic'
      end
      def edit_discussion_post
         begin
           @post = ForumThread.find(params[:id])          
           if @post.poster_id == @my.id
               @discussion = @post.discussion
               if request.post?
                #save the changes
                    @post.message = params[:message] 
                    @post.subject = params[:topic]
                    @post.save
                    if @post.errors.empty?
                        redirect_to :action=>'view_topic',:id=>@discussion.id ,:page=>params[:page]                   
                    else                      
                        r_msg @post.errors
                        redirect_to :back
                    end
                return
               end              
               render :template=>'forums/new_topic'  
               return                  
           end
         rescue Exception=>e

         end
         redirect_to :back      
      end
      def delete_discussion_post
         begin
           post = ForumThread.find(params[:id])
           if post.poster_id == @my.id
              if post.is_header
                 post.discussion.destroy
                                  
              else        
                 post.destroy                   
              end
              expire_this_forum_fragment
           end
         rescue Exception=>e

         end
         redirect_to :back
      end
      def view_topic
          @forum_owner = forum_owner
          @discussion = get_discussion params[:id]          
          unless @discussion
            redirect_to :action=>'forum_topics'
            return
          end
          if request.post?
            @discussion.increment! :num_views 
            redirect_to :action=>'view_topic'
            return
          end          
          @paginator,@posts = paginate @discussion.posts,:per_page=>10
          render :template=>'forums/view_topic'
      end 
      def forum_topics      
          @forum_owner = forum_owner
          unless read_fragment({:action=>'forum_topics',:page=>params[:page],:order=>params[:order],:sort=>params[:sort]})            
            order = case params[:sort]  
                        when "co" then "created_on"
                        when "v" then "num_views"
                        when "r" then "num_posts"
                        else  "last_post_time"
                    end       
            order += " " + (params[:order] == "asc" ? "ASC" : "DESC")
            @paginator,@discussions = paginate :forums,:order=>order,:per_page=>15,
                                      :conditions=>["context_guid =#{@forum_owner.guid}"]
            unless read_fragment({:hot_topics=>true})
                @hot_topics = Forum.find(:all,:order=>"num_posts DESC",
                      :conditions=>"num_posts > 0 AND last_post_time >= #{Time.now.utc.ago(1.week).to_i} AND context_guid = #{@forum_owner.guid}",:limit=>4)
            end   
          end
          render :template=>'forums/show_topics'         
      end
      
    end  
end