#load File.join(RAILS_ROOT,'lib/rails_mod_extensions.rb')
#load 'lib/app_mods.rb'
#load 'lib/vendor_activerecord_mods.rb'

class ApplicationController < ActionController::Base

  DefaultErrorMessage = "An error has occured. Please try again." unless const_defined? "DefaultErrorMessage"
  before_filter  :authenticate,:authorize,:save_gui_state,:detect_browser
  layout "main_layout.rhtml"
#  def profile_memory_leak
#      load 'lib/memory_profiler.rb'
#      MemoryProfiler.start(:string_debug=>true)
#      render :text=>'memroy profiler started'
#  end
  include ExceptionNotifiable  
  def invalidate_chat
      render :update do |page|
        page << <<-eof
            sessionChecker.stop();
            $('chatarea').update('<div class="server-alert-message"> You have logged in to oycas somewhere else. </div>')
        eof
      end        
  end
  def get_chat_box
    render :text=>"<iframe  id='oycasGabbly'  src='http://cw.gabbly.com/gabbly/cw.jsp?e=1&dnc=true&nick=#{params[:name]}&t=#{params[:id]}' scrolling='no' style='width:100%; height:400px' frameborder='0'></iframe>"
  end
  def chat_window
      if request.xhr?
          if params[:check_session] and not @my.session_is_valid?(session)
              invalidate_chat
          else
            session['chat' + (params[:id] || "")] = nil
            render :nothing=>true
          end
          return
      end
      session['chat' + (params[:id] || "")] = true
      render :template=>"shared/chat_window",:layout=>false;
  end
  def report_bug
      if request.post?        
        if request.xhr?
          render_p 'shared/report_bug'
          return
        end    
        Notifier::deliver_report_bug(@me,params[:bug_report],request.env['HTTP_USER_AGENT'])       
      end
      redirect_to :back
  end
  protected 
    exception_data :additional_data

    def additional_data
      { :userdetails => @me }
    end

    def set_tab action="",tabset="",tab=""
       session['tab_manager'][tabset] = tab 
       session['tab_manager']['action'] = action
    end

    def detect_browser
        require 'lib/vendor.rb'
        @browser = Vendor.new(request.env['HTTP_USER_AGENT'])
#        @browser.version
    end
    def authenticate
        begin
          if session['student'] 
                @me = Student.find(session['student'])   
                @my = @I = @me
                $my = $I = $me = @my 
                #when ever we access the site we record the access time 
                #howver if it is not desirable to record for a whole session
                #or just for an action pass the no stamp as paramaters or put it in the session object

                @I.timestamp_access! unless request.post? or session['no_stamp'] or params['no_stamp'] or component_request? != nil                           
          elsif session['admin']
                #@admin = Admin.find(session['admin'])
                @admin = Admin.find(session['admin']) 
                begin
                  raise if controller_name == "admin"                  
                  @dummy = @me = Student.find(session['dummy']) #login a student as a dummy student
                  @me.timestamp_access! unless session['no_stamp'] or params['no_stamp'] or component_request? != nil
                rescue 
                  @dummy = session['dummy'] = nil #need this because if there is dummy login when we can't go to the students 
                                                  #home page 
                  @me = Admin.piggy  
                end
                @my = @I = @me
                $my = $I = $me = @my               
          else 
            raise
          end
          @user_authenticated = true
        rescue Exception=>e
          @user_authenticated = false
        end  
        return true        
    end
    def authorize               
        return true if @user_authenticated
        if action_name == 'chat_window'
          #we need this here because if we are logged in somewhere else
          #the chat is open we want to invalidate the chat
          invalidate_chat
#        elsif controller_name == "oycas"
#          return true        
        else
          flash[:post_login_params] = params
          redirect_to :controller=>'access',:action=>'login'         
        end
        return false
    end
#      def email_pattern
#         "^[\w-]+(\.[\w-]+)*@([a-z0-9-]+(\.[a-z0-9-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?$"
#      end
#      def check_format(address)
#          return true if address.downcase.match(/^[\w-]+(\.[\w-]+)*@([a-z0-9-]+(\.[a-z0-9-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?$/)
#          return false
#      end
#      def get_email_domain(address)          
#            return address.match(/\w+\.\w+$/).to_s
#      end  
#      def valid_email_format?(address)
#          return true if address.downcase.match(/^[\w-]+(\.[\w-]+)*@([a-z0-9-]+(\.[a-z0-9-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?$/)
#          return false
#      end
#      def get_email_domain(address)          
#          return address.match(/\w+\.\w+$/).to_s
#      end  
  private 
    def return_default_error dom_id
         r_msg dom_id=>DefaultErrorMessage    
    end
    def update_error_hash(key,value)
          if @error_hash[key]
              @error_hash[key] = [@error_hash[key]] unless @error_hash[key].is_a? Array
              @error_hash[key] << value
          else   
              @error_hash[key] = value
          end
#          @error_hash[key].flatten!         
    end
    def r_msg *args
        args.flatten!
        @error_hash ||= {}
        error_hash = @error_hash        
        begin       
        (args || []).each do |arg|            
            if arg.is_a? Hash
              arg.each do |k,values|
                  values = [values].flatten
                  values.each do |v|
                    if v.is_a? ActiveRecord::Errors                        
                        msg = v.instance_variable_get("@errors").values.inject([]) do |array,err_msgs|                                                                                     
                              array << err_msgs
                              array
                        end
                        msg.flatten!                                
                      update_error_hash(k,msg)  
                    elsif v.is_a? String
                      update_error_hash(k,v)
                    end  
                  end                
              end              
            elsif arg.is_a? ActiveRecord::Errors              
              arg.instance_variable_get("@errors").stringify_keys.each do |attr,msg|                                       
#                  raise "Using Base Attribute for error passing" if attr == 'base'
                  update_error_hash(attr,msg)
              end              
            end        
        end
       rescue Exception=>e
            raise e
       end
       unless error_hash.empty?
          msg_options = {}   
          msg_options[:type] = @error_hash.delete(:type)
          msg_options[:hide] = @error_hash.delete(:hide)                       
          msg_options[:position] = @error_hash.delete(:position)
          msg_options[:block] = @error_hash.delete(:block)
          flash[:system_msgs] = @error_hash               
          flash[:system_msg_options] = msg_options                 
       end
#       return_msg error_hash unless error_hash.empty?
    end
#    def return_msg(options={})
#        
#    end       
#    
    def md5_of str
      str = str.to_s
      require 'digest/md5'
      Digest::MD5.hexdigest(str)
    end
    alias original_paginate paginate
    def paginate(collection,options={})
        if collection.is_a? Array          
            per_page = options[:per_page] || 10   
            parameter = options[:parameter] || 'page'
            current_page = params[parameter]
            paginator = Paginator.new self,collection.size,per_page,current_page                                               
            paginator.current_page = paginator.last_page  if current_page == 'last'

            return [paginator,collection[paginator.current_page.offset..paginator.current_page.offset+per_page-1]]          
        else         
          original_paginate collection,options
        end
    end  
    def save_gui_state                      
        if params[:tabset] and params[:tab] #reqeuest is post
          session['tab_manager'] = {} unless session['tab_manager']
          session['tab_manager'][params[:tabset]] = params[:tab]                  
        elsif request.get?
           unless (session['tab_manager']['action'] rescue "") == params[:action]                       
              session['tab_manager'] = {}
              session['tab_manager']['action'] = params[:action]               
           end                  
        end
        return true    
    end   
   

   

end
