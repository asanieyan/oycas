class StudentController < ApplicationController            
    
#      
      before_filter :instantiate_student , :profile_filter_methods
      skip_before_filter :profile_filter_methods,:only=>%w(report_photo report_note current_klasses add_as_friend students_in_full friends rate_student rate_profile)
      
      
#      create_navigation ['#{@studentb.f_name}\'s Profile',{:url=>{:action=>'profile'}}],
#                            ["Shared Class Notes",{:url=>{:action=>'show_notes'}}],
#                            ["View Photos",{:url=>{:action=>'photo'},:if=>"@studentb.visible_album_counts(@me) > 0"}]
      
      include Note
      include PhotoAlbum 
      include Scrapalious
      include StudentDisplay 
      add_student_display_methods "@studentb","@studentb.friends",'friend'         
      add_scrap_methods "@studentb"          
      add_note_methods_for "@studentb"
      add_album_methods "@studentb"
      
#      caches_action :show_personal
#      caches_action :show_contact
      
      def render_menus          
#          student_menu = add_menu('#{@studentb.full_name}')
          student_menu = add_menu('#{image_tag(@studentb.thumb_image,:style=>";float:left;height:25px;margin-right:10px;") + " " + @studentb.full_name + "&nbsp;&nbsp;"}',:action=>'profile')
          student_menu.add_submenu('Profile',:action=>'profile')
          student_menu.add_submenu('Photos',:action=>'photo',:if=>"@studentb.visible_album_counts(@me) > 0") 
          student_menu.add_submenu('Binder',:action=>'show_notes',:if=>"@studentb.notes.not_anonymous.size > 0")          
                 
      end
      def show_general
          render_p 'student/show_general_info'
      end

      def show_personal
           render_p 'student/show_personal_info'
      end
      def show_contact
           render_p 'student/show_contact_info'
      end
      verify :method=>:post,:only=>%w(current_klasses)
      def current_klasses
          begin

            school = School.find(params[:school_id])
            if @I.can_see_current_classes_of? @studentb
                    
                    render_p 'school/current_klasses',
                         {'klasses'=>@studentb.klasses_at(school),'student'=>@studentb,'school'=>school}                
            end            
            return
          rescue Exception=>e

          end
          render :nothing=>true
      end
      def rate_student        
        #cookies[@studentb.guid.to_s] = {:value=>'1',:path=>'rate_students',:expires=>4.hours.from_now}
        rating = params[:rating].to_i
        rating = rating.abs % 6
        PopularityRate.rate(@me,@studentb,rating)
        render :nothing=>true          
      end      
      
      def rate_profile
          #render the mini profile of the student
          render_p 'student/student_rate_profile', {'student'=>@studentb}
      end
      def profile 
        @student = @studentb
        render :template=>'my/home'
      end      
      def students_in_full
          if @I.can_see_friends_of?(@studentb)
            super
           else
            redirect_to :action=>'profile'
           end
      end
      alias friends students_in_full
      def remove_as_friend
           StudentFriend.remove_friendship @me, @studentb
           redirect_to :back  
      end
      def cancel_friend_request
            FriendRequest.delete_all("requester_id = #{@my.id} AND requestee_id = #{@studentb.id}")              
            redirect_to :back
      end
      def add_as_friend
          unless @I.can_add_as_friend? @studentb
            render :nothing=>true
            return
          end  

          if request.post? and not request.xml_http_request? 
              begin                                
                @req =  FriendRequest.find_or_create_by_requester_id_and_requestee_id(@my.id,@studentb.id)
                @req.created_on = Time.now.utc
                @req.message = params[:message] if params[:message] 
                @req.save
                Notifier::deliver_friend_request(@me,@studentb) if @studentb.add_friend_notification
              rescue Exception=>e
                 
              end
              redirect_to :back                            
          else 
               @req =  FriendRequest.find_request_out(@me,@studentb)
               render_p 'student/add_friend'  
          end     
    end    
    verify :method=>'post',:only=>%w(report_person report_photo report_note)
    before_filter :only=>%w(report_person report_photo report_note) do |c|
           contr_binding = c.send(:binding)
           eval_str = <<-"EOF"
                if @I.am_pig?
                  render :nothing=>true                 
                end
           EOF
           eval(eval_str,contr_binding)
    end
    def report_person
        if not request.xml_http_request?            
            ReportedItem.generate_report(@me.id,@studentb.id,'profile',@studentb.id,params[:reason],params[:comments])         
            redirect_to :back
            return
        end
        render_p 'report_person'
    end
    def report_photo
        begin
          set_photo_owner #used in app_mods 
          return unless set_album_instance          
          @photo = AlbumPhoto.find(params[:id]) 
          raise unless @photo and @photo.student_id == @studentb.id  and @album.visibility >= @my.relation_with(@studentb)
          if not request.xml_http_request?
              ReportedItem.generate_report(@me.id,@studentb.id,'photo',@photo.id,params[:reason],params[:comments])
              redirect_to :back
              return
          end                   
        rescue 
           render :text=>" "
           return 
        end
        render_p 'report_photo'   
    end
    def report_note
    
    end    
  private 
      def instantiate_student            
            begin
              @studentb = Student.find(:first,:conditions=>["guid = ? " ,params[:sid]])
              raise if @studentb.is_suspended? and not @I.am_admin? # can only see the student if it is suspended
              if @I.am?(@studentb) and params[:rlevel].to_i > 0 #this is for when you are viewing your own profile from others perspective
                  @studentb = @me.dup_as params[:rlevel]                 
              end
              raise unless @studentb
            rescue Exception=>e             
              redirect_to :controller=>'my',:action=>'home'
              return
            end                         
      end
      def profile_filter_methods
           begin 
             raise unless @I.can_see_profile_of?(@studentb) or @admin             
           rescue                      
              @students = [@studentb]
              flash[:profile_access_denied] = true
              render :template=>'student/students_browse_view'
              return false
           end
      end

end

