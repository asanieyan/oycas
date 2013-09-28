class FacebookController < ApplicationController
  API_KEY = "b559a002102b87e269dabbe058fc2754"
  SECRET = "646c837bea90217679d424b188716b8b"
  
  require 'lib/rfacebook/lib/facebook_rails_controller_extensions.rb'
  
  include RFacebook::RailsControllerExtensions
#  layout false
  
  def facebook_api_key
    API_KEY
  end 
  def facebook_api_secret
    SECRET
  end  
  def finish_facebook_login

  end  
  skip_before_filter :authorize
  before_filter :check_request_is_from_facebook_server, :facebook_authorize
  def index 
    render :text=>"<fb:redirect url='my_classes' />"
  end
  def login
    render :text=>"<fb:redirect url='index' />"
  end
  def login_to_oycas
     CACHE["facebook_" + session.session_id] = @my.id
     url = url_for( :host=>"www.oycas.com",
                    :controller=>'access',
                    :action=>'login_from_facebook',
                    :id=>session.session_id,
                    :timestamp=>((params[:timestamp] || "true") == "true" ? true : false),
                    :facebook_post_login=>params[:url] || "/my",
                    :r=>fbsession.session_user_id)      
     
     render :text=>"<fb:redirect url='#{url}' />"    
  end

  def my_classes
  
  end 
  def my_messages
    @unread_msgs = @my.inbox_messages.select{|m| not m.is_read}
  end
  def my_classifieds      
    @replies = ClassifiedPostReply.find(:all,:conditions=>["created_on > ?",@my.logout_time])
  end
  private
    def check_request_is_from_facebook_server
      if not fbsession.session_user_id
          url = "http://www.facebook.com/add.php?api_key=#{API_KEY}"
          render :text=>"<fb:redirect url='#{url}' />"
          return false
      end 
      return true
    end    
    def facebook_authorize
#        if session['student']            
#            s = Student.find(session['student']) rescue nil                                 
#        else
#            
#            if s
#              s.login_to(session) 
#            end
#            p session['student']
#        end
        s  =  Student.find(:first,:conditions=>"facebook_uid=#{fbsession.session_user_id}")
        if s
          @me = @I = @my = $I = $me = $my = s 
          return true
        end
        if action_name == 'login' #the user is loging into oycas
          s = Student.find_by_username_and_password(params[:username],md5_of(params[:password]))
          if s and s.rank == :student
            s.facebook_uid = fbsession.session_user_id
            s.save;
            s.login_to(session)              
            render :text=>"<fb:redirect url='index' />"
            return              
          end
          @login_failed = true           
        end        
        render :action=>'login_to_oycas' ,:layout=>false
     end   
end
