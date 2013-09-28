class AccessController < ApplicationController  
  skip_before_filter :authorize
  before_filter :check_login, :except=>%w(login_from_facebook)
  def login_from_facebook
   begin
     id = CACHE.get("facebook_" + params[:id])
     CACHE.delete("facebook_" + params[:id])     
     s = Student.find(id) 
     if s.facebook_uid == params[:r].to_i
       s.login_to(session) 
       session['no_stamp'] = true 
        #since they might go back and forth between
        #facebook and oycas we don't want them to lose the data 
     end 
     redirect_to URI::decode(params[:facebook_post_login] || "/my")
   rescue Exception=>e
     redirect_to :action=>'index'  
   end   
  end
  def tour
    
  end
  def activate
     #parse the activation link 
     @title = "Activating Oycas! Account"          
     guid,rand = params[:id].split("r")
     reg = Registration.find_by_guid_and_random_number(guid,rand)              
     if reg                   
          if not %w(undergraduate graduate).include?(reg.school_status.to_s)#the staff and faculty 
              SchoolStaff.add_entry reg.school_id, reg.email,"registered as school staff or facluty"
              r_msg "login-message"=> render_to_string(:inline=> <<-"eof"
                      <div>At this point oycas does not support faculty or staff members</div>
                      <div> for more information <%=link_to_help 'click here',"h0"%>.</div>              
              eof
              )
              reg.destroy
              redirect_to :action=>'login' 
              return
          end
          first_name,last_name = reg.name.split(" ",2)
          Student.create_new(first_name,last_name,reg.email,reg.password,School.find(reg.school_id))
          reg.destroy          
          r_msg 'login-message'=>"Your account has been activated. Please login.",:type=>'success'
          redirect_to :action=>'login'                                      
     else
        r_msg 'reg-message'=> 'Invalid activation code. Please register again.'   
        redirect_to :action=>'register'
     end 
     
  end
  def get_school
      domain = EmailHelper::get_domain(params[:email])
      if domain.size == 0
        render :nothing=>true
        return
      end
    render :update do |p|
      school = School.find_by_email_domain(domain) 
      if not school  

        p << "$('reg-message').update('')"
        p.message.show({'reg-message'=>"We are sorry but your school is not supported yet. #{link_to 'Click here','/access/schools'} to see the list of supported schools."},
          :position=>"bottom",:type=>"alert")
       
      else        
        p.message.show({'reg-message'=>"#{image_tag school.logo ,:style=>'height:50px;float:left;margin-right:10px;'} <span class=''><br>You are registering for #{school.name}</span><div style='clear:left'></div>"},
          :position=>"bottom",:type=>"alert")
      end
    end
  end
  def register        
      @title = 'Register in Oycas!'             
      if request.post?      
         begin
          reg = Registration.find_by_email(params[:email]) 
          if (reg)
            Notifier::deliver_signup_notification(reg)
            r_msg :type=>"info","login-message"=> "Thanks for registering! We just sent you a confirmation email to #{reg.email}. <span style='font-weight:normal'> Click on the confirmation link in the email to complete your registration</span>"
            redirect_to :action=>'login'
            return
          end          
          if not EmailHelper::valid_format?(params[:email])
              #needs to go back 
              #raise ArgumentError, "That's not a valid email and you know it"       
              r_msg "reg-message"=>"Please enter a valid email address."
              raise
          end      
          edomain = EmailHelper::get_domain(params[:email])
          school = School.find_by_email_domain(edomain)                    
          if (school and not school.active) or not school           
              if not school
                r_msg "reg-message"=> "We are sorry but your school is not supported yet. <a href='/access/schools'>Click here</a> to see the list of supported schools.",
                :position=>"bottom",
                :type=>"alert"
                raise
              else
                r_msg "reg-message"=> "Guess what! We are going to support #{school.name} in near future. Come back soon. we are waiting for you.",:type=>'info'
                raise              
              end
          else 
              #university is supported               
              flash[:email_is_valid] = true
              student = SchoolMember.find_by_school_id_and_registered_email(school.id,params[:email])
              if student
                r_msg "reg-message"=> "You are already registered. <a href='login'> Login Here </a>"
                raise
              end
              email_username = params[:email]#.match(/.*?@/).to_s.strip  
              staff = SchoolStaff.find(:first,:conditions=>["school_id = #{school.id} AND email_address LIKE ?",email_username])
              part_error = render_to_string(:inline=> <<-"eof"
                      <div>At this point oycas does not support faculty or staff members</div>
                      <div> for more information <%=link_to_help 'click here',"h0"%>.</div>              
              eof
              )
              if staff 
                r_msg "reg-message"=>render_to_string(:inline=>" This email has been tagged as a faculty or staff member.#{part_error}")                     
                raise
              end

          end

          reg = Registration.new(:school_id=>school.id,
            :email=>params[:email],
            :school_status=>params[:school_status],
            :name=>params[:name],
            :password=>params[:password])  
          reg.password_confirmation = params[:confirm_password] 
          reg.save
          if not reg.errors.empty? 
            r_msg "reg-message"=>reg.errors
            raise
          end          
#          if reg.password != params[:confirm_password]
#            r_msg "reg-message"=>"Please enter your confirmation password the same as your password"
#            raise
#          end          
          Notifier::deliver_signup_notification(reg)
          r_msg :type=>"info","login-message"=> "Thanks for registering! We just sent you a confirmation email to #{reg.email}. <span style='font-weight:normal'> Click on the confirmation link in the email to complete your registration</span>"
          redirect_to :action=>'login'
          return
          
      rescue Exception=>e
#        p e.message        
      end
      end

  end
  def reset_password
      if not params[:id] 
        if request.post?
          student = Student.find(:first,:conditions=>["username LIKE ?",(params[:email] || "").strip])        
          if student and not student.is_suspended?
            id = "#{student.guid}r#{md5_of(student.id * student.school.id)}"
            r_msg :type=>'info','reset-message'=>"<div style='font-weight:normal'>An email has been sent to your email #{student.username}. <br> Follow the link in the email and reset your password.</div>"
            Notifier::deliver_reset_password(student,id)
          elsif student and student.is_suspended?
            r_msg 'reset-message'=>["This account has been suspended and it is under review. You can't reset password for this account. "]
          else
            r_msg 'reset-message'=>["Invalid email. Please enter a valid email."]
          end
          redirect_to :back
          return
        end
      else
          guid,hash = params[:id].split("r",2)
          student = Student.find_by_guid(guid)
          id = "#{student.guid}r#{md5_of(student.id * student.school.id)}"
          if (id == params[:id])            
            if request.post?
                if (params[:password].length >= Student::PasswordLength and params[:password] ==  params['confirm_password'] ) 
                  student.password = params[:password]
                  student.save
                  r_msg 'login-message'=>"Your password has been reset. Please login.",:type=>'success'
                  redirect_to :action=>'login'
                  return
                else
                  r_msg 'pass-msg'=>"Your password must be at least #{Student::PasswordLength} characters long." if params[:password].length < Student::PasswordLength  
                  r_msg 'pass-msg'=>"Password should match the confirmation." if params[:password] !=  params['confirm_password']  and params[:password].length > 0
                end
            end
            render :template=>'access/reset_form' 
            return            
          end  
          redirect_to :action=>'login'
      end     
  end
  def schools
      
  end
  def login    
    if request.post?
       #find the student    
       flash.keep
       student = Student.find_by_username_and_password(params[:username],md5_of(params[:password]))       
       if student and student.rank == :student
           login_student(student)
          if flash[:post_login_params]     
              redirect_to  flash[:post_login_params] 
          else
            redirect_to :controller=>'my',:action=>'home'          
          end
       else
              admin = Admin.find(:first,:conditions=>["email LIKE ? AND password LIKE ?",params[:username],md5_of(params[:password])])
              if admin                                
                session['admin'] = admin.id
                redirect_to :controller=>'admin', :action=>'control_panel'
                return 
              end                          
              r_msg :hide=>'true','login-message'=>"Incorrect email or password.<div style='font-weight:normal'>Passwords are case sensitive. Please check your CAPS lock key.</div>"
              redirect_to :action=>'login'
              return
       end
        
    end
  
  end
  def index
    #admin login engine as well
    @title = 'Login to Oycas!'
  end
  def logout
      reset_session
      redirect_to :action=>'index'    
  end
  private     
    def login_student(student)
          student.login_to(session)
    end
    def check_login                               
        if session['student']     
               @me = Student.find(session['student'])                    
               if action_name == 'logout'
                 @me.logout_from(session)
                 redirect_to :action=>'index'  
                 return true
               else
                 redirect_to params[:facebook_post_login] || "/my"
               end
        elsif session['admin'] and action_name != 'logout'
              @admin = Admin.find(session['admin'])              
              redirect_to :controller=>'admin',:action=>'control_panel'
        end
        return true
    end

end
