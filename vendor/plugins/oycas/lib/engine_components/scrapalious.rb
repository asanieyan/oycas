module Scrapalious
    def self.included(base)
        base.class_eval do 
          def self.add_scrap_methods scrap_owner,options={}    
              @scrap_owner = scrap_owner #can be a class,me,student,schoool,project
#              before_filter :can_student_post_scrap?,:only=>''
#              before_filter :can_student_see_scrap?,:only=>'desk'
              #verify :method=>'post',:only=>%w(desk delete_desk_msg post_msg_to_desk)
          end
          before_filter :only=>%w(post_msg_to_desk delete_desk_msg) do |contr|
              
          end                       
        end        
        base.send :include, InstanceMethods
    end    
    module InstanceMethods           
        def desk                            
              @scrap_owner = eval(self.class.instance_variable_get("@scrap_owner"),binding)
              
              if @scrap_owner.can_student_see_scrap?(@me)
                @paginator, @scraps = paginate :scraps,:per_page=>15,
                            :order=>'created_on DESC',
                            :conditions=>"reciever_guid = #{@scrap_owner.guid}"
              
                render :partial=>'shared/show_scraps'
              else
                render :nothing=>true
                
              end
        end
        def delete_desk_msg
            #can only delete a desk message
            #if the desk message belongs to @me
            #of @I am the @scrap_reciever
            begin
              s = Scrap.find(params[:id])
              if s and (s.sender_id == @my.id or s.reciever_guid == @my.guid) #either i am a sender or the reciever to delete a scrap
                Scrap.delete(s.id)   
              end
            rescue
            
            end
            redirect_to :back              
        end
        def post_msg_to_desk
              #I am postings a message to some student with guid                           
             scrap_owner = eval(self.class.instance_variable_get("@scrap_owner"),binding)
             begin 
                 if params[:reciever] #reciever is always a student
                   reciever = Student.find(:first,:conditions=>['guid=?',params[:reciever]])   
                   raise unless reciever.can_student_post_scrap? @me
                 else                   
                    reciever = scrap_owner
                 end                            
                 Scrap.create(  
                        :reciever_guid=>reciever.guid,
                        :sender_id=>@my.id,
                        :message=>params[:message]
                 )                                
             rescue Exception=>e

                                          
             end
             if reciever == scrap_owner
                 desk
             else
                 render :nothing=>true
             end
        end
    
    end
end