  class AdminController < ApplicationController

    before_filter :check_admin

    include ActionView::Helpers::TextHelpers

    def control_panel          
      redirect_to :action=>'admins'
    end
  
############################################################
# Admin related methods
############################################################

    def render_menus
#        add_menu :admins,:action=>'admins'
        schools = add_menu :schools,:action=>:schools
#        add_menu(:articles,:action=>"articles").add_sub_menu(:compose,:)
        msg = add_menu(:messages)
          msg.add_sub_menu(:sent_items,:action=>"sent_items")          
          msg.add_sub_menu(:compose,:action=>"compose")
        student = add_menu(:student)
        student.add_sub_menu(:name_requests,:action=>'change_name_requests')
        student.add_sub_menu(:suspensions,:action=>:suspended_students)
        student.add_sub_menu(:reports,:action=>:reports)        
        student.add_sub_menu(:dummy_accounts,:action=>:dummy)        

        articles = add_menu(:articles)
        articles.add_sub_menu(:list_articles, :action=>:list_articles)
        articles.add_sub_menu(:upload_article, :action=>:upload_article)        

    end
    def admins
        if params[:admin_id] 
          @selected_admin = Admin.find(params[:admin_id]) rescue @selected_admin=nil
        end             
        @admin_list = Admin.find(:all)  
    end

    def login_dummy_student
      begin
        raise unless request.post?
        s = Student.find(params[:id])
        if not s.rank == :dummy 
          session['no_stamp'] = true
        else
          session['no_stamp'] = nil
        end
        session['dummy'] = s.id
        redirect_to "/my"
      rescue Exception=>e
        p e.message
        redirect_to :back
      end
    end
    def dummy
        @school = School.find(:first)
        @paginator,@dummies = paginate :student,:order=>'login_times DESC',
                  :conditions=>"rank LIKE 'dummy'",:per_page=>30        
    end


  ############################################################
  # articles related methods
  ############################################################

  def upload_article
    if request.get? then
    elsif request.post? then
      begin
        document = params[:document]
        if document == nil then
          raise "NoDocumentException"
        end
        content = strip_tags(document.read, { :except => ['p'] })
     

        Article.create!(:title => params[:title], :content => content, :created_on => Time.now)
      rescue Exception => e
        puts e
      end
      redirect_to :action => 'list_articles'
    end
  end

  def list_articles
    @articles = Article.find :all
  end

  def view_article
    begin
      @article = Article.find(params[:article_id])
    rescue Exception => e
    end
  end

  def delete_article
    begin
      Article.destroy(params[:article_id])
    rescue Exception => e
    end
    redirect_to :action => 'list_articles'
  end
 

############################################################
# Student related methods
############################################################
  
    def registrations 
      if request.post?
        begin
          reg = Registration.find(params[:id])
          raise unless reg
          Notifier::deliver_signup_notification(reg)
        rescue Exception=>e
          p e.message
          redirect_to :back
          return
        end
      end
    end
    def suspended_students 
      conditions = "account_status LIKE 'suspended' AND rank <> 'dummy'"
      @paginator, @students = paginate :students,:order=>"last_name ASC",
                            :conditions=>conditions    
    end
    def sent_items
      if request.post?
        IntranetMessage.delete_all(params[:delete],0) rescue nil        
        redirect_to :back
        return;
        
      end
      render :action=>"messages/sent_items"
    end
    def compose
        if request.post?
          errors = nil
          if params[:subject].strip == ""
           errors =  {'r_message'=>'Please enter a subject'}
          else  
              message = @admin.send_message(:all,params[:subject],params[:message])               
              errors = {'r_message'=>message.errors} unless message.errors.empty?
          end  
          if (errors rescue nil)
            r_msg errors
            redirect_to :back
          else
            redirect_to :action=>"sent_items"
          end
          return
        end
        render :action=>"messages/compose"
    end
    def change_name_requests
        if request.post?            
            if params[:approve]
              req = ChangeNameRequest.find(params[:approve])
              req.student.set_name!(req.requested_name)
            elsif params[:reject]
              req = ChangeNameRequest.find(params[:reject])             
              @admin.send_message req.student,"Requested name not approved!",
                  "Your requested name '#{req.requested_name}' has not been approved by the admin panel."                 
            end
            req.destroy
            redirect_to :back
            return
        end
    end
############################################################
# School related methods
############################################################
#    verify :method=>:post,:only=>%w(edit_school_info)

#    def edit_school_info
#      @school = School.find(params[:id])
#      if not request.xhr?
#        @school.attributes= params[:school]
#        @school.save
#        redirect_to :back;
#        return
#      end
#      render :layout=>false;
#    end
    def set_school_dates
     if request.post?
       @school = School.find(params[:id]) rescue
       begin
         render :nothing=>true
         return
       end
       if not request.xhr?
         begin
         %w(class_start class_end exam_end).each do |l|
           month = params[l]["month"].to_i
           day = params[l]["day"].to_i
           raise if day == 0 or month == 0    
           @school.current_semester.instance_eval <<-eof
            self.#{l} = self.season.get_date_compared_to_start(month,day)
           eof
           @school.current_semester.save
         end 

         rescue         
           r_msg :error=>"Invalid dates"
         end
         redirect_to :back
         return
       end       
       render :layout=>false;
     end
    end
    def schools
      begin
        @school_list = School.find(:all)
        if params[:schid] != nil then
          @selected_school = School.find(:first, :conditions => ["guid=?",params[:schid]])
        end
      rescue Exception => exc
          
      end
    end
    def school_op
        begin
          school = School.find(params[:id])
          if params[:activate]
            school.active = :y
            school.save
          elsif params[:deactivate] and school.students.size == 0
            school.active = nil
            school.save
          elsif params[:delete] and school.students.size == 0
              school.destroy          
          end
        rescue Exception=>e
          p e.message
        end
        redirect_to :back 
    end



  ############################################################
  # messages related methods
  ############################################################
#  def messages
#      # provide list of schools to template
#      begin
#  
#        @system_messages = IntranetMessage.sys_msg_find(:all)
#        @system_messages,@paginator = get_paginator_for @system_messages,params[:page],10    
#
#      rescue Exception => exc
#        logger.debug = exc
#      end
#      
#  end

#  def compose
#    
#  end
#    
#  def create_message
#    begin
#         sm = IntranetMessage.create_sys_msg params[:subject],params[:message]             
#    rescue Exception => exc
#      if exc.to_s != "errors" then
#        flash[:error_hash] = {"exception"=>exc}
#      else
#        flash[:error_hash] = error_hash
#      end
#    end
#    if flash[:error_hash] == nil then 
#        redirect_to :action=>'messages'
#    else
#      redirect_to :action=>'compose', :params=>{:subject=>params[:subject], :message=>params[:message]}
#    end
#    
#  end  
#  
#  def delete_message(id=nil, is_group=false)
#      if id == nil then
#        id = params[:message_id]
#      end
#
#      message_object = IntranetMessage.sys_msg_find(id) rescue message_object=nil
#
#      if message_object!= nil then
#        begin
#          #message_object[0].destroy()
#          IntranetMessage.delete_all(message_object[0].id, 0)
#        rescue Exception => exc
#          flash[:error_hash] = {"delete error"=>"could not delete message -> #{exc}"}
#        end
#      else
#        flash[:error_hash] = {"message error"=>"message not found"}
#      end
#      if is_group==false then
#        redirect_to :action=>'messages'
#      end
#  end  
#  
#  def group_operation
#      begin
#        params[:ids].each do |id|
#          delete_message(id, true)
#        end
#      rescue Exception => exc
#        flash[:error_hash] = {"delete error"=>"could not delete message -> #{exc}"}
#      end
#      redirect_to :action=>'messages'
#  end






  ############################################################
  # reports related methods
  ############################################################

  def reports     
     @r_type_id = ReportType.find(params[:item]).id rescue nil
     
     options = {:conditions=>[],:order=>[]}
     unless @r_type_id
        options.update({:order => ['last_report_time DESC']})
     else        
        condition = ActiveRecord::Base.send(:sanitize_sql,['report_type_id = ?',@r_type_id])
        options.update({:order=>['num_reports DESC,last_report_time DESC'],:conditions=>[condition]})
     end    
     if params[:v] 
         begin         
           @student = Student.find(params[:v])
         rescue
            redirect_to :action=>'reports'
            return
         end
         options[:order] = ["resolved ASC"] + options[:order]
         options[:conditions] << "student_id = #{params[:v]}"
     else
         options[:conditions] << "resolved IS NULL"  unless params[:show_resolved] == "true"     
     end    
     options[:order] = options[:order].join(",") 
     options[:order] = nil if options[:order] == ""
     
     options[:conditions] = options[:conditions].join(" AND ")
     options[:conditions] = nil if  options[:conditions] == ""
     @reports = ReportedItem.find(:all,options)
     @paginator,@reports = paginate @reports 
     
  end  
  #actions on reports 
  before_filter :prepare_before_action, 
      :only=>%w(delete_classified delete_photo send_warning suspend mark_resolved) 

  private
      def send_notification subject,message
        Notifier::deliver_violation_notification(@report.reported_student,subject,message)
        @admin.send_message(@report.reported_student,subject,message.gsub(/\n/,'<br>'))
      end
      def prepare_before_action
        @report = ReportedItem.find(params[:id])  
        return false if @report.is_resolved? or not request.post?    
        @to_name = @report.reported_student.full_name 
        @notification_message =  params[:message]            
      end  
  public
 
  def unsuspend
     s = Student.find(params[:id]) rescue nil
     return unless s and s.is_suspended?                
     @notification_message = params[:message] || <<-"eof"
       Welcome Back      
            
       We would like to inform you that the suspension on your account has been lifted and you can start using the oycas service. Please go to the sign in page and login.         
     eof
     unless request.xhr?
       s.is_unsuspended!           
       Notifier::deliver_violation_notification(s,"Account UnSuspended",@notification_message) 
       redirect_to :back
       return
    end           
    render_p 'admin/violation_notification'  
  end
  #resolving methods 
  def delete_classified
      @notification_message ||= <<-eof
          The following classified post has been removed due to following reasons 
            <%@report.flags.summary.each do |r| %>
                * <%= r['reason'] %> (<%=pluralize(r.num.to_i,'flag')%>)
            <%end%>
          More violation on your account may result in your account suspension at Oycas.
          ------------------------------------------------------------------------------
          title:#{@report.item.title}
          <%=strip_tags(@report.item.description)%>
                            
      eof
      unless request.xhr?
          @report.has_been_resolved "Classified Post has been deleted"
          @report.item.destroy
          send_notification("Classified Post Removed",@notification_message)           
          redirect_to :back
          return
      end
      render_p 'admin/violation_notification'
  end
  def delete_photo      
      src_file =  File.join(RAILS_ROOT,"public",@report.item.album.get_medium_photo(@report.item))
      dest_file_name = File.basename(src_file)
      dest_web_path =  "/shared_images/admintmp/#{dest_file_name}"     
      @notification_message =  params[:message] || (<<-"eof"
            the photo #{request.protocol + request.host + dest_web_path} has been removed from your photo album '#{@report.item.album.name}' because of #{@report.flags.summary.num_reports} reported violatoins of:                                    
            
            <%@report.flags.summary.each do |r| %>
                * <%= r['reason'] %>
            <%end%>            
            More violation on your account may result in your account suspension at Oycas.
      eof
      )
      if not request.xhr? 
        return unless @report.report_type == :photo                
        FileUtils.mkdir_p(File.join(RAILS_ROOT,"public/shared_images/admintmp"))      
        FileUtils.copy_file(src_file,File.join(RAILS_ROOT,"public",dest_web_path))      
        send_notification("Offensive Photo Deleted",@notification_message)
        @report.item.album.delete @report.item
        @report.has_been_resolved "Deleted Image <br> <img src='#{dest_web_path}'>"
        redirect_to :back     
        return
      end
      
      render_p 'admin/violation_notification'
  end  
  def suspend
      return if  not s = @report.reported_student      
      #find all of the violation of this student     
      @notification_message = params[:message] || <<-"eof"
         Your account has been suspended due to the following violations:
         <%=render_violation_summary_for(@report.reported_student)%>        
        Your account will remain suspended while we continue our investigation. For further information or to discuss your suspension please contact admin@oycas.com.         
      eof
      unless request.xhr?
        s.is_suspended!
        @report.has_been_resolved "Student account suspended"      
        @report.item.album.delete(@report.item) rescue nil #just in case the report is about the photo                      
        send_notification("Account Suspended",@notification_message) 
        redirect_to :back
        return
      end     
      render_p 'admin/violation_notification'
      
  end  
  def mark_resolved
      unless request.xhr?
          @report.has_been_resolved params[:comments]
          redirect_to :back
          return
      end
      render_p 'admin/marking_resolved'
  end
  def send_warning
      @notification_message = params[:message] || <<-"eof"
       You have been warned for something something        
       <%=render_violation_summary_for(@report.reported_student)%>     
      eof
      unless request.xhr?
          @report.has_been_resolved "Warning Sent"
          send_notification("Account Suspension Warning",@notification_message) 
          redirect_to :back
          return
      end
      render_p 'admin/violation_notification'
  end
  
  def send_msg
      return unless student = (Student.find(params[:id]) rescue nil )
      unless request.xhr?
          Notifier::deliver_violation_notification(student,params[:subject],params[:message])      
          redirect_to :back
          return
      end
      @send_msg = true
      @to_name = student.full_name      
      render_p 'admin/violation_notification'
  end
  def view_report
        begin
          @r = ReportedItem.find(params[:id])        
        rescue
            redirect_to :action=>'reports'
            return
        end
  end
 
 private
    def check_admin
        unless @admin
            redirect_to :controller=>'my'
            return true
        end
        @controller_custom = <<-eof
          <style>
            #content-panel{            
              padding:20px;
              background-color:white !important;
              height:200px;  
              border-top:1px solid #C0C0C0;                         
            }            
          </style>  
        eof
    end     
end
