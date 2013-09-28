class MyController < ApplicationController    

#    verify :method=>'post',
#      :except=>%w(profile my_settings home photo 
#                  create_album album messages compose read_message friends show_desk_scraps students_in_tab ),
#      :redirect_to=>{:action=>'home'}            
    
    before_filter :admin_redirect 
    include PhotoAlbum
    include Scrapalious
    include StudentDisplay 
    include News
    include Note    
    alias friends students_in_full
    alias rate_friends rate_students
    def students_in_full; redirect_to :action=>'friends';end;
    def rate_students; redirect_to :action=>'rate_friends';end;
    def render_menus        
        add_menu('Home',"/my/home")        
        settings = add_menu("My Settings")
          settings.add_sub_menu(:edit_profile,"/my/profile")
          settings.add_sub_menu(:edit_account,"/my/my_settings")
        
        add_menu('Photo',"/my/photo").add_sub_menu(:create_album,{:action=>'create_album',:id=>'create'},:pop=>true,:pop_options=>{:title=>"Create New Album"})
        add_menu('My Friends',"/my/students_in_full").add_sub_menu('Invite contacts',:action=>"invites")
        add_menu(:my_binder,"/my/show_notes")        
        #add_menu("My Courses",{:depends_on_sub=>true},nil,MyHelper::render_course_items)      
    end
    add_album_methods "@me"
    add_news_for "@me","@my.guid"
    add_scrap_methods "@me"
    add_student_display_methods "@me","@my.friends","friend"    
    add_note_methods_for "@me"
    
    def index
          redirect_to :action=>'home'
    end
    def set_online_status
      @my.update_attribute('online_status',params[:id]) rescue nil
      render :nothing=>true
    end
    def invites
        
     
    end
    verify :method=>:post,:only=>%w(facebook email_invite)
    def email_invite
      if not request.xhr?
          
          emails = params[:addrs] || ""
          emails << params[:file].read rescue ""
          emails = emails.gsub(',',' ').gsub(/\s+/,' ').split(' ').uniq[0..500].select{|email| EmailHelper::valid_format?(email)}
          unless emails.empty?
            MiddleMan.new_worker(:class => :inviter_worker,
                         :args => [:email,@my.id,emails]).delete rescue nil    
            r_msg :imessage=>"Your contacts have been invited to oycas",:type=>"success"                         
          else
            r_msg :imessage=>"The email addresses you have entered are not valid. Please enter valid email addresses"
          end
          redirect_to :action=>"invites"
          return
      end
      render :layout=>false
    end
    def facebook
#        params[:username] = "asanieya@sfu.ca"
#        params[:password] = "v3j7n1"
        if not request.xhr?
          msg = ""
          begin
            username = params[:username]
            password = params[:password]
            unless username and username.size > 0 
              raise(msg = "Please enter your facebook username and password")
            end
            unless password  and password.size > 0 
              raise(msg = "Please enter your facebook password<br><div class='nobold'>It is against our policy to store this password</div>")
            end
            fb = FacebookBot.new({:email => username, :password => password})
            if !fb.logged_in?
              raise(msg = "Unable to login with the provided credentials!" )
            end
            MiddleMan.new_worker(:class => :inviter_worker,
                         :args => [:facebook,@my.full_name,username,password,params[:invite_message]]).delete rescue nil          
            r_msg :imessage=>"Your contacts from facebook have been invited to oycas",:type=>"success"
          rescue Exception=>e           
              r_msg :imessage=>msg
              redirect_to :action=>"invites"
              return                          
          end
          redirect_to :action=>"invites"
          return                        
        end
        render :layout=>false;
    end
    def my_settings 
        #four tabs account, school, privacy, notification 
        if request.post?     
            id = ""
            options = {}
            anchor = nil
            if params[:remove_email]
                StudentContactEmail.delete(["default_email IS NULL AND student_id = #{@me.id} AND id = ?",params[:remove_email]])
                redirect_to :back
                return                                                                   
            elsif (params[:email_change] || "").size > 0
                #change the default email to this id 
                begin
                  email = StudentContactEmail.find(params[:email_change])
                  raise unless email.student_id == @my.id and email.confirmed and not email.default_email
                  @my.default_contact_email = email
                  r_msg 'email-title'=>"Contact email successfully changed to <strong>#{email.contact_email}</strong>",
                      :type=>'success'
                rescue Exception=>e 
                
                end
                redirect_to :back
                return
            elsif params[:new_email]                 
                  self.class.send :include, ApplicationHelper
                  id = 'email-title'                  
                  message = nil
                  email = nil
                  if not EmailHelper::valid_format?(params[:new_email])
                      message = "Invalid email format. Please enter a valid email"
                  elsif (StudentContactEmail.find(:first,:conditions=>["contact_email LIKE ?",params[:new_email]]))                                                                      
                      message = "This email is already in use. Please enter a valid email"
                  else 
                      begin                  
                          email = StudentContactEmail.create :student_id=>@me.id,:contact_email=>params[:new_email]                 
                          Notifier::deliver_confirm_email(email,@me) 
                          message = "A confirmation email has been sent to your new contact email address."                                       
                          options = {:hide=>true,:type=>'info'}
                      rescue Exception=>e
#                            p e.message 
                      end                                        
                  end                                              
             elsif params[:resend_confirmation]
                  begin                      
                      email = StudentContactEmail.find(params[:resend_confirmation])                      
                      raise unless email.student_id == @my.id and not email.confirmed
                      Notifier::deliver_confirm_email(email,@me)                   
                  rescue Exception=>e
   
                  end
                  
             elsif params[:password_change]
                    #needs to md5 the password
                    id = 'password-title'
                    begin
                      old_password = params['password']['old'] rescue ""
                      new_passwod = params['password']['new'] rescue ""
                      confirmed_password = params['password']['confirm'] rescue ""
                      if (@my.password_eql?(old_password)) 
                         if (new_passwod).size < Student::PasswordLength
                           message = "Your new password must be at least #{Student::PasswordLength} character long"                       
                         elsif new_passwod !=  confirmed_password
                           message = "You must enter the same password twice in order to confirm it."                       
                         else
                           @me.password= new_passwod
                           @me.save
                           options[:type] = 'success'
                           message = "Password successfully changed."                       
                         end
                      else
                          message = "Your old password was incorrectly typed."
                      end                       
                    rescue Exception=>e
                          message = "An error occured during password change. Please try again."
                    end
             elsif params[:security_question]                      
                  id = 'secure'
                  anchor = 'center'
                  q = params[:security][:question] rescue ""
                  a = params[:security][:answer] rescue ""
                  message = []
                  if (q.size < 10)
                      message << "Please enter a longer security question."                  
                  end
                  if (a.size < 5)
                     message << "Please enter a longer security answer."
                  end
                  if message.empty? #no errro so far
                      @me.security_question = q
                      @me.security_answer = a
                      if (@me.save rescue nil)
                        message = "Security question successfully changed."
                        options[:type] = 'success'                        
                      else
                        message = "An unexpected error occured. Please try again"
                      end
                      
                                      
                  end
             elsif params[:timezone]                 
                 id = 'timezone'                
                 timezone = TZInfo::Timezone.new(params[:timezone_name]) rescue nil
#                 timezone = tzinfo_from_timezone(TimeZone.new(timezone))
                 if timezone 
                   @me.tz = timezone
                   @me.save
                   message = "Timezone successfully changed to <strong>#{timezone.name}</strong>."
                   anchor = "center"
                   options = {:type=>'success'}
                 end
             elsif params[:name_change]
                if @my.rank == :dummy #change the dummy name 
                  @my.set_name!(params[:new_name])
                  redirect_to :back
                  return
                end
                id = 'change_name'
                anchor = 'center'
                req = ChangeNameRequest.create(@me,params[:new_name]) 
                unless req.errors.empty?
                    message = req.errors.on('requested_name')
                else
                    options[:type] = 'success'
                    message = "A requested has been sent to the admin. Your name will change as soon as it is reviewed."                    
                end
             elsif params[:cancel_school_request]
                  #cancel the request if membership is valid and it has not been confirmed and it belongs to me                   
                  SchoolMember.delete_all ["id = ? AND student_id = #{@my.id} AND confirmed IS NULL ",params[:cancel_school_request]]
             elsif params[:join_school]               
                  id = 'school-select'               
                  new_email = (params[:school_email] || "")                 
                  if EmailHelper::valid_format?(new_email)                      
                      domain =  EmailHelper::get_domain new_email
                      school = School.find(:first,:conditions=>["email_domain LIKE ? ", domain])
                      if school
                          membership = SchoolMember.find(:first,:conditions=>[" school_id = #{school.id} AND student_id = #{@my.id}"])
                          if not membership or (membership.student_id == @me.id and not membership.confirmed)
                              if not membership
                                membership = SchoolMember.create :school_id=>school.id,:student_id=>@me.id,:registered_email=>new_email 
                              elsif membership.registered_email != new_email
                                membership.registered_email = new_email
                                membership.save                                
                              end
                              Notifier::deliver_confirm_school(membership,school,@me) 
                              message = "A confirmation email has been sent to your new contact email address."                                
                              options[:type]='success'
                          else
                             membership.student_id == @me.id ? 
                                 message = "You are already a student at #{school.name}" :
                                 message = "This email belongs to another student registered in <strong> #{school.name}</strong>." +
                                  "Please enter your own email addresss." 
                             
                          end
                      else
                          message = "The email you entered did not match any of our supported schools."
                      end
                      
                  else                    
                    message = "Invalid email format. Please enter a valid email"
                  end
                  
                 
             elsif params[:remove_school]
                  id ='school-select'
                  school = @my.schools.detect{|s| s.id == params[:remove_school].to_i}                  
                  if (school && !school.is_primary)
                          school.drop_student(@me)
                          options[:type] = 'success'
                          message = 'Saved Changes'                                  
                  end
             elsif params[:primary_school]
                 soon_to_be_primary = SchoolMember.find(:first,:conditions=>["student_id = #{@me.id} AND school_id = ?",params[:primary_school]])
                 current_primary = SchoolMember.find(:first,:conditions=>"student_id = #{@me.id} AND default_school LIKE 'y'")
                 if soon_to_be_primary and current_primary and current_primary != soon_to_be_primary
                    SchoolMember.transaction do 
                      soon_to_be_primary.default_school = 'y'
                      current_primary.default_school = nil
                      current_primary.save;soon_to_be_primary.save
                      message = "#{@me.school.name} is your default school now."
                      options[:type] = 'success'
                      id = 'school-select'
                    end
                    
                 end
             
             end                          
            r_msg({id=>message},options || {})           if message 
            params[:t] = (request.env["HTTP_REFERER"] || "").match(/&|\?t=(\w+)/)[1] rescue nil
            redirect_to :action=>"my_settings",:t=>params[:t],:anchor=>anchor
            return        
        end
        
        
    end  

    def notifications         
        if request.post?        
          @my.attributes.each do |k,v|
             if k =~ /notification/ 
               (params[k]? eval("@my.#{k} = 'y'")  :  eval("@my.#{k} = ''")) rescue next
             end
           end
           @me.save;
           r_msg :notification_msg=>"Saved changes.",:type=>"success"
        end
        redirect_to :back
        return
#       render_p 'my/settings/notifications'
    end
#    def account_settings render_type = nil
#       render_p 'my/settings/account'
#    end
#    def school_settings render_type = nil
#       render_p 'my/settings/school_settings' 
#    end
    def profile    
          if request.xml_http_request? and params[:v]
              student = @me.dup_as params[:v].to_i
              @manual_rel_level =  params[:v].to_i  
              @student = student
              @observing_my_profile_from_another_perspective = true
              @profile_view = render_to_string(:template=>'my/home' ,:layout=>false)
              render_p 'my/view_own_profile' 
              return
          end
          flash.keep
    end
    def edit_general_profile                
        if not request.xml_http_request? 
            begin 
              year = params["date"]["year"].to_i
              month = params["date"]["month"].to_i
              day = params["date"]["day"].to_i        
              @my.birthdate = Date.new(year,month,day)
              %w(sexual_orientation birthdate_show_format birthdate_visibility relationship_status
                  gender relationship_status_visibility sexual_orientation_visibility).each do |field_name|
                  @my[field_name] = params["my"][field_name] ||  @my[field_name]
              end    
#              @my.attributes= params[:my]
              @me.save
              r_msg :message=>["Profile Information Saved."],:type=>'success'                          
            rescue Exception=>e
              r_msg :message=>["An error has occured. Please try again."]
            end           
            redirect_to :action=>'profile'
            return
        end                
        render_p "my/profile/edit_basic_profile"
        
    end
    def edit_personal_profile
        if not request.xml_http_request? 
            begin 
              @me.profile.attributes= params[:profile]                    
              @me.profile.save                        
              r_msg :message=>["Personal Information Saved."],:type=>'success'
              expire_fragment :controller=>'student',:sid=>@my.guid,:action=>'show_personal'
            rescue
              r_msg :message=>["An error has occured. Please try again."]
            end
            redirect_to({:action=>'profile'}, :method=>:get)
            return
        end    
        render_p "my/profile/edit_personal_profile"
    end
    def update_region
        render_p 'my/profile/region_update','my_country'=>params[:my_country],'my_sub_region'=>(@me.profile.sub_region rescue nil)
    end
    def edit_contact_profile
        if not request.xml_http_request?             
            begin 
              @me.profile.attributes= params[:profile]                    
              @me.profile.save 
              params[:email].each do |email_id,visibility|
                  begin
                    email = StudentContactEmail.find(email_id)
                                        
                    raise unless email.student_id == @my.id and email.confirmed
                    email.visibility = visibility
                    email.save
                  rescue
                  
                  end  
              end
              expire_fragment :controller=>'student',:sid=>@my.guid,:action=>'show_contact'                       
              r_msg :message=>["Contact Information Saved."],:type=>'success'
            rescue
              r_msg :message=>["An error has occured. Please try again."]
            end
            redirect_to({:action=>'profile'}, :method=>:get)
            return
        end          
        render_p "my/profile/edit_contact_profile"
    end


    def edit_profile_privacy        
       if not request.xml_http_request?
          begin
            params[:mini] ||= {}
            %w(send_msg_option add_friend_option 
               current_courses_option
               birthdate_option relationship_status_option 
               friend_option rate_option                
               status_option).each do |attr|                                
                  @my[attr]=params[:mini][attr]                                                                   
              end            
              @my.profile_visibility = params[:profile_visibility]
              @me.save              

          rescue Exception=>e
               return_default_error :message
          end   
          r_msg :message=>"Profile privacy successfully saved.", :type=>'success'
          redirect_to :back
          return
       end
       render_p "my/profile/edit_profile_privacy"
    end
    def edit_profile_add_ons  
         if not request.xml_http_request?
            begin
                @my.current_course_visibility = params[:current_course_visibility] || @my.current_course_visibility
                @my.course_archive_visibility = params[:course_archive_visibility] || @my.course_archive_visibility
                @my.friend_visibility = params[:friend_visibility] || @my.friend_visibility
                @my.desk_visibility = params[:desk_visibility]   || @my.desk_visibility             
                (params[:albums] || []).each do |album_id,album_visibility|
                    album = StudentPhotoAlbum.find(album_id)
                    next unless album.student_id = @my.id
                    album.visibility = album_visibility.to_i
                    album.save rescue next
                end
                r_msg :message=>"Profile Information Saved.",:type=>'success'
                raise unless @I.save              
            rescue Exception=>e
                 return_default_error :message
            end   
            
            redirect_to :back
            return
         end                
        render_p "my/profile/edit_profile_add_ons"
    end
    def edit_profile_picture              
        if not request.xml_http_request? 
            begin 
              if (params[:picture_file] || "").size > 4.megabytes
                 r_msg :message=>["Profile picture is too large."]
              else
                @my.profile_picture = params[:picture_file]
                r_msg :message=>["Profile Picture Saved."],:type=>'success'
              end
            rescue Exception=>e
#              p e.message
              r_msg :message=>["An error has occured. Please try again."]
            end
            redirect_to :action=>'profile'            
            return
        end          
        #render_p "my/profile/show_picture_profile"
    end

################################################################################################################  
    def reject_friend_request
          FriendRequest.delete_all(["requestee_id = #{@my.id} AND requester_id = ?",params[:id]])              
          redirect_to :back
    end       
    def recieved_friend_requests
      if request.xml_http_request?
        @showing_recieved_requests = true;
        @friend_request_paginator, @friend_requests = paginate @my.recieved_friend_requests,:per_page=>3
        render_p 'my/friend_request'
      end
    end
    def delete_scraps
        if params[:scraps_to_be_deleted] == '0'
          Scrap.delete_all("reciever_guid = #{@my.guid}")
        elsif params[:scraps_to_be_deleted] == '1'
          Scrap.delete_all(["reciever_guid = #{@my.guid} AND created_on < ? ",Time.now.utc-2.weeks])
        end
#        render :nothing=>true
        redirect_to :back
    end
    def sent_friend_requests
      if request.xml_http_request?
        @showing_sent_requests = true;
        @friend_request_paginator, @friend_requests = paginate @my.sent_friend_requests,:per_page=>3
        render_p 'my/friend_request'
      end        
    end
    def my_mood_status
      if request.xml_http_request?
          if params[:set]
              @me.mood_status= params[:value]                                                         
          elsif params[:load]              
             render :text=>(@me.mood_status || "")  
             return     
          end                
      end     
      render_p 'student/printout_status',{'student'=>@me}
    end
    def home
       
#       self.class.process_cgi(CGI.new,{:session_key=>"_session_id"})

#        x = CGI::Session.new(CGI.new, 'new_session' => true,'session_id'=>session.session_id)
#        x.instance_eval("@session_id='#{session.session_id}'")
#        x.delete        
#        p self.class.session_options         
#       p session
       
       @student = @me
       render :template=>'my/home',:locals=>{'student'=>@me}              
    end

#################################################ALBUM#############################    
    skip_before_filter :authorize, :save_tab_state,  :only=>%w(set_flex)
    session :off, :only=>%w(set_flex)
    def set_flex
        begin
          cookies[params[:box]] = {:value=>(params[:close] == "true" ? 'close' : nil),:expires => 1.year.from_now,
              :path=>(request.env['HTTP_REFERER'].sub(/http.*?com/,'') || "/")}            
        rescue 
         
        end
        render :nothing=>true    
    end   

    def add_more_files_to_album          
      if not request.xml_http_request? and request.post?
        begin       
           @album.save_photos(params.keys.select {|k| k =~ /File\d+/ }.inject([]){ |tempfiles,pic_file_param_name| tempfiles << params[pic_file_param_name]; tempfiles }) 
        rescue Exception=>e
            p e.message                             
            r_msg :message=>'There is a problem with our upload server. Please try again.'          
        end              
        redirect_to :action=>'album',:a=>@album.guid
        return
      end
      render_p "my/album/add_photos_to_album"
    end
    
    def edit_album_info
        if request.post?  
               begin 
                  @album.attributes= params[:album]
                  raise unless @album.save 
                  r_msg :message=>'Album information has been saved.',:type=>'success'                                                   
               rescue
                  unless @album.errors.empty?
                      r_msg :message=>@album.errors.full_messages
                  else
                      return_default_error :message                    
                   end
               end           
               redirect_to :back
               return               
        end
        
    end
    def do_photo_caption
        if params['do'] and request.xhr?
              @photo = AlbumPhoto.find(:first,:conditions=>["student_photo_album_id = #{@album.id} AND guid = ? " , params[:photo]])                      
              case params['do'] 
                when 'get_caption'
                  render :text=>((@photo.caption rescue nil) || "")
                when 'save_caption'
                   @photo.caption= params[:value]
                   @photo.save
                   if @photo.caption
                      if params[:truncate] == "true" 
                        render :inline=>"<%=break_down(truncate(@photo.caption),10)%>"
                      else 
                        render :inline=>"<%=break_down((@photo.caption),10)%>"
                      end                      
                   else
                      render :text=>"<span style='color:#A0A0A0' > Click here to set caption </span>"
                   end
                end
        end                
    end
    def edit_photo_settings        
        if request.post?         
            if params[:photo_action] == 'Move' or params[:photo_action] == 'Delete'
                  photo_ids = params[:pictures]
                  if photo_ids.size > 0                      
                      AlbumPhoto.with_scope(:find=>{:conditions=>"student_photo_album_id = #{@album.id}"}) do
                          @pictures = AlbumPhoto.find(photo_ids)                                                                         
                      end                      
                      if @pictures
                          if params[:photo_action] == 'Move'
                               return unless set_album_instance params[:new_album],"@new_album"
                               @album.move_all @pictures, @new_album
                          else

                               @album.delete_all @pictures
                          end                      
                      end

                  end                                 
            elsif params[:album_cover]
                @album.cover= params[:album_cover]           
            end
            redirect_to :back
            return
        end     
           
    end
    def album     
         if request.post? and params[:d] == "true"
           @album.destroy
           redirect_to :back
           return            
         end     
      params[:m] = %w(edit_photo_settings edit_album_info).include?(params[:m]) ? params[:m] : "edit_photo_settings"
      if params[:m] == "edit_photo_settings"   
        @paginator,@photos = paginate @album.photos,:per_page=>20
      end
      if request.xhr? and params[:set_cover] == "true"
          @photos =  @album.photos
          @paginator = nil
          render_p 'my/album/edit_album_photos'
          return
      end
    end     
    before_filter :set_album_instance,
        :only=>%w(do_photo_caption edit_photo_settings edit_album_info album add_more_files_to_album) 

    verify :method=>:post, :only=>'create_album'
    def create_album
        if params[:id] == "create" and  not request.xml_http_request?        
            album = StudentPhotoAlbum.new
            begin            
              album.attributes= params[:album]
              album.student_id = @my.id          
              if album.save                                     
                  redirect_to :action=>'album', :a=>album.guid                
              else
                  redirect_to :back            
                  r_msg album.errors                  
              end
            rescue Exception=>e                  
                  redirect_to :back            
                  r_msg :message=>DefaultErrorMessage  
            end            
            #redirect_to :action=>'album',:a=>album.guid
            return
        end          
        render_p 'my/album/create_photo_album'      
    end
########################################MESSAGES############################################    
   
    def messages
      if params[:id]        
        begin           
          @folder = params[:folder]
          if params[:folder] == "in" or params[:folder] == "sm"          
            msg_recv_record = IntranetMessageRegistry.find(:first, :conditions=>["reciever_id = #{@my.id} AND id=?",params[:id]])
            if  msg_recv_record.folder.to_s != params[:folder]
                redirect_to :action=>'messages',:folder=> msg_recv_record.folder,:id=>msg_recv_record.id 
                return
            end           
            msg_recv_record.is_read = :y
            msg_recv_record.save
            @message = msg_recv_record.message_record 
            @message.id = msg_recv_record.id
          elsif params[:folder] == "si"
            @message = IntranetMessage.find(:first,:conditions=>["sender_id = #{@my.id} AND id = ?" , params[:id]])            
            raise if @message.deleted_by_sender
          end
          raise unless @message
        rescue Exception=>e             
          redirect_to :action=>'messages',:id=>nil
          return
        end
        @folder = params[:folder]
        render :action=>'my/messages/read'             
        return
      end
      @messages = case params[:folder]
                    when 'si' then @my.sent_messages
                    when 'sm' then @my.saved_messages
                    when 'in',nil then @my.inbox_messages
                    else 
                      redirect_to :action=>'messages'
                      return
                  end
      @folder = params[:folder] || "in"
      @paginator, @messages = paginate @messages,:per_page=>50
    end 


    def rescue_action_in_public(exception)
      puts exception
    end

    def compose      
      @message = IntranetMessage.new({:subject=>flash[:subject],:body=>flash[:body]})      
      @recipients = flash[:recipients] ? Student.find(flash[:recipients]) : []       
          
      begin       
        if params[:m]            
            @replied_msg = IntranetMessageRegistry.find(:first, :conditions=>["reciever_id = #{@my.id} AND id=?",params[:m]])
            msg = @replied_msg.message_record
           
            raise if msg.sender_id == 0                            
            @message.body = <<-eof  
                 <br>          
                 ----------------------------------------------------<br>
                 On #{@my.time(msg.created_on).strftime("%m/%d/%y").downcase} #{msg.sender.full_name} wrote: <br>
                 #{msg.body}
            eof
            @message.body.gsub!(/\s/,' ') 
           
            raise unless @I.can_send_message_to? msg.sender          
            @recipients << msg.sender
        elsif params[:id]                          
            s = Student.find_by_guid(params[:id])
            raise unless @I.can_send_message_to? s
            @recipients << s       
        end
      rescue Exception=>e #if the rid is fake         
#        p e.message
        redirect_to :action=>'compose',:id=>nil
      end

    end    
    verify :method=>:post,:only=>%w(create_message sent_messages saved_messages inbox)
    def create_message                   
          flash[:subject] = params[:subject]
          flash[:message] = params[:message]
          begin
            recipients = Student.find(params['recipients'] )   
            flash[:recipients] = recipients.map{|r| r.id} 
            message = IntranetMessage::deliver_message(@me,recipients,params[:subject],params[:message] ) 
            recipients.each do |r|
              Notifier::deliver_private_message_notifier(@me,r,params[:subject],params[:message]) if r.send_message_notification
            end
            if message.errors.empty?
              redirect_to :action=>'messages',:folder=>'si'
            else
              r_msg 'compose_err_msg'=>message.errors
              redirect_to :back
            end
          rescue
              render :nothing=>true
              return
          end                       
    end    
    def mark_message
        ids = (params[:msg_ids] || []).join(",")  
        begin
          is_read = params[:id] == "false" ? "NULL" : "'y'" 
          IntranetMessageRegistry.update_all "is_read = #{is_read} ", "id IN (#{ids}) AND reciever_id = #{@my.id}"
        rescue Exception=>e 
        
         
        end
        redirect_to :back
    end
    def save_message   
      
      ids = (params[:msg_ids] || []).join(",")
   
      begin 
        IntranetMessageRegistry.update_all "folder = 'sm'", "folder LIKE 'in' AND id IN (#{ids}) AND reciever_id = #{@my.id}"
      rescue Exception=>e

      end
      redirect_to :back
    end     
    def delete_message   
       
      ids = (params[:msg_ids] || []).join(",")     
      begin
        if params[:folder] == 'in' or params[:folder] == 'sm' #if the message is recieved  delete the record            
            IntranetMessageRegistry.delete_all("reciever_id = #{@my.id} AND id IN (#{ids})")
        elsif params[:folder] == 'si'
            IntranetMessage.delete_all ids,@my.id
        end
      rescue Exception=>e
       
      end      
      redirect_to :back
    end   
######################################################################################
    private
      def tzinfo_from_timezone(timezone) 
        
        TZInfo::Timezone.all.each do |tz|          
          if tz.current_period.utc_offset.to_i == timezone.utc_offset.to_i
            return tz
          end
        end
        return nil   
      end    
      def admin_redirect
            if @admin and not @dummy
              redirect_to :controller=>'admin',:action=>'control_panel'
              return false
             end
             return true            
      end

end
