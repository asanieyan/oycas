class ProjectController < ApplicationController

#  require 'project/project_member.rb'
  require 'project/project_meeting.rb'
  require 'project/project_task.rb'
  require 'project/project_folder.rb'

  before_filter :validate, :except => [:create_new_project, :commit_create_new_project]
 
  
  has_side_menu ['home','meetings', 'tasks', 'calendar', 'documents', 'forum', 'chat', 'settings'], 'controller/pid/action/id'



  include StudentDisplay
  include Scrapalious
  include Forums
  
  
  add_forum_methods "@project"
  add_scrap_methods "@project"

  add_student_display_methods "@project", "@project.students", "project member"
 
  alias forum forum_topics

  #################################################################################
  # Project Creation and Settings Methods
  #################################################################################

  def create_new_project
      
  end

  def commit_create_new_project
    message = nil

    @klass = Klass.find(params[:pid]) rescue @klass = nil
    @enrolled_student = @klass.student_registered? @me
    
    if @klass != nil && @enrolled_student != nil then
      @new_project=nil
      begin
        ProjectMember.transaction do
          Project.transaction do
            @new_project = Project.create(:klass_id => @klass.id, :title => params[:title], :description => params[:description])

            if @new_project.valid? == false then
                message = @new_project.errors
                raise "errors"
            end
            
            @new_project_member = ProjectMember.create(:project_id => @new_project.id, :student_id => @me.id, :project_email_address => params[:project_email_address], :is_activated => 'y')

            if @new_project_member.valid? == false then
                message = @new_project_member.errors
                raise "errors"
            end

            @folder = ProjectFolder.create(:project_id=>@new_project.id, :folder=>"general")

            filepath = "/shared/project_documents/#{@new_project.id}"

            if not FileTest.exists?("#{filepath}/general") then
              FileUtils.mkdir_p("#{filepath}/general")
            end

          end
        end
        redirect_to :action => "home", :pid => @new_project.id
      rescue Exception => exc
        if exc.to_s != "errors" then
          message = {"project_error"=>exc.to_s}
        end
        r_msg message
        redirect_to :action => "create_new_project", :pid => params[:pid], :title => params[:title], :description => params[:description], :project_email_address => params[:project_email_address]
      end
    else
      redirect_to :controller => "my", :action => "home"
    end
    
  end



  def invite_new_member

    temp = ProjectMember.find(:all, :conditions=>['project_id=?',@project.id]) rescue temp = []

    member_ids = Array.new
    temp.each do |t|
      member_ids << t.student_id.to_s
    end

    temp = KlassEnrollment.find(:all, :conditions=>['klass_id=?',@project.klass_id]) rescue temp = []

    all_ids = Array.new
    temp.each do |t|
      all_ids << t.student_id.to_s
    end
    
    @memberlist = KlassEnrollment.find(all_ids-(member_ids&all_ids)) rescue @memberlist = nil

  end



  def commit_invite_new_member
    message={"project_error"=>"Members added successfully", :type=>"success"}    
    begin
      students = Student.find(params[:ids])
      students.each do |student|
          if @project.klass.has_student?(student)              
              ProjectMember.create(:project_id=>@project.id, :student_id=>student.id, :project_email_address=>student.emails.default.address, :is_activated=>'y')              
          end
      end
    rescue Exception=>e     
      redirect_to :back
      return
    end 
    r_msg 'project_error'=>"Members are added successfully.",:type=>'success'
    redirect_to :back
     
  end
  def confirm_remove_project_members
    flash[:commit_ok]=true
    flash[:self_delete]=nil
    if params[:members] == nil then
      message = {"project_error"=>"No members selected for removal"}
      r_msg message
      redirect_to :action=>'settings', :pid=>@project.id
      return
    end

    if params[:members].index(@me.id.to_s) != nil then
      flash[:self_delete]=true
    end

    #check for full delete of all members..
    project_members = Array.new
    @project.project_members.each do |member|
      project_members << member.student_id.to_s
    end  

    flash[:delete_project]=nil    
    if project_members.sort == params[:members].sort then
      flash[:delete_project]=true
    end

    render_p 'project/confirm_remove_project_members'

  end
  def commit_remove_project_members
      begin
        ProjectMember.destroy_all("id IN (#{params[:members].join(',')}) AND project_id = #{@project.id}")
      rescue
      
      end
      redirect_to :back
      return
    message = nil
    temp_id = @project.id
    if flash[:commit_ok] != nil then
      if flash[:commit_ok]==true then
        if flash[:delete_project] != nil then 
          if flash[:delete_project] == true then
            rval = @project.destroy
            if rval[0]==true then
              @project.freeze
              message = {"project_error"=>"Project deletion successful.",:type=>"success"}
              r_msg message
              redirect_to :action=>'home', :pid=>temp_id
            else
              r_msg rval[1]
              redirect_to :action=>'settings', :pid=>temp_id
            end
            
          else

            begin
              ProjectMember.transaction do
                params[:members].each do |m|
                  ProjectMember.delete(m)
                end
              end
            rescue Exception => exc
              message = {"project_error"=>"Error in deletion of member(s)"}
              r_msg message
              redirect_to :action=>"settings", :pid=>temp_id
            end
            r_msg message
            redirect_to :action=>"settings", :pid=>temp_id
          end
        end

      end
    else
      redirect_to :action=>'home', :pid=>temp_id      
    end
  end


  #################################################################################
  # Home Area Methods
  #################################################################################

  def index
    redirect_to :action => "home"
  end

  def home
  end

  def upcoming
    render_p 'project/upcoming'
  end

  #################################################################################
  # Settings Methods
  #################################################################################

  #subsection main page
  def settings
  end

  def project_settings render_type = nil
    render_p 'project/project_settings'
  end
  
  def personal_settings render_type = nil
    render_p 'project/personal_settings'
  end
  
  def update_project_settings
    message = {'project_message'=>'Update sucessful!', :type=>"success", :hide=>true}

    #project = Project.find(params[:pid]) rescue project = nil
    if @project != nil then
      begin
        Project.transaction do
          @project.title = params[:title]
          @project.description = params[:description]
          if @project.valid? == false then
            message = project.errors
            raise "errors"
          else
            @project.save!
          end
        end
      rescue Exception => exc
        if exc.to_s != "errors" then
          message = {"project_error"=>exc.to_s}
        end
      end
    else
      message = {'project_error'=>'Could not find specified project'}
    end
    
    r_msg message
    redirect_to :action=>"settings", :pid=>params[:id]
  end

  def update_personal_settings
    message = {'project_message'=>'Update sucessful!', :type=>"success", :hide=>true}

    project_member = ProjectMember.find(params[:member_id]) rescue project_member = nil
    if project_member != nil then
      begin
        ProjectMember.transaction do
          project_member.project_email_address = params[:project_email_address]
          if project_member.valid? == false then
            message = project_member.errors
            raise "errors"
          else
            project_member.save!
          end
        end
      rescue Exception => exc
        if exc.to_s != "errors" then
          message = {"project_error"=>exc.to_s}
        end
      end
    else
      message = {'project_error'=>'Could not find specified project member'}
    end

    r_msg message
    redirect_to :action=>"settings", :pid=>params[:id]
  end

  #################################################################################
  # Meetings Methods
  #################################################################################

  def meetings
  
  end

  def schedule_new_meeting
    @memberlist = ProjectMember.find(:all, :conditions=>['project_id=?',@project.id]) rescue @memberlist = []


    if params[:fromcalendar] != nil then
      flash[:year] = params[:year]
      flash[:month] = params[:month]
      flash[:day] = params[:day]
    end

  end

  def commit_schedule_new_meeting
    message = nil

    tz = TZInfo::Timezone.get(@project.klass.school.time_zone)

    begin
    
      if params[:day] == nil || params[:month] == nil || params[:year] == nil then
        message = {"project_error"=>"Meeting date incorrect."}
      end
 
      if params[:year].to_i < tz.utc_to_local(Time.now.utc).year then#Time.now.year then
        message = {"project_error"=>"The meeting date must be equal to or later than today's date!"}
      elsif params[:year].to_i == tz.utc_to_local(Time.now.utc).year then#Time.now.year then
        if params[:month].to_i < tz.utc_to_local(Time.now.utc).month then#Time.now.month then
          message = {"project_error"=>"The meeting date must be equal to or later than today's date!"}
        elsif params[:month].to_i == tz.utc_to_local(Time.now.utc).month then#Time.now.month then 
          if params[:day].to_i < tz.utc_to_local(Time.now.utc).day then#Time.now.day then
            message = {"project_error"=>"The meeting date must be equal to or later than today's date!"}
          end
        end
      end      
      
      if params[:members] != nil then
        if params[:members].length == 0 then
          message = {"project_error"=>"There must be at least one participant for a meeting"}        
        end
      else
        message = {"project_error"=>"There must be at least one participant for a meeting"}
      end

      if message != nil then raise "errors" end
    
      #assemble date
      if params[:ampm]=="pm" then
        hour = params[:hour].to_i + 12
      else
        hour = params[:hour].to_i
      end
      dt = DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i, hour, params[:minute].to_i,0)
      md = tz.local_to_utc(dt)
      meeting_date = md#Time.utc(params[:year], params[:month], params[:day], params[:hour], params[:minute],0,0)

      ProjectMeetingParticipant.transaction do
        ProjectMeeting.transaction do
          @project_meeting = ProjectMeeting.create(:project_id=>@project.id, :title=>params[:title], :scheduled_on=>meeting_date, :scheduled_by=>@me.id)
          if @project_meeting.valid? == true then
            params[:members].each do |m|
              @project_meeting_participant = ProjectMeetingParticipant.create(:project_meeting_id=>@project_meeting.id, :participant_id=>m)
            end
          else
            message = @project_meeting.errors
            raise "errors"
          end
        end
      end
      message = {"project_error"=>"meeting successfully scheduled", :type=>"success"}
      
      r_msg message
  
      if params[:fromcalendar] != nil && params[:fromcalendar] != "" then
        redirect_to :action=>'calendar', :pid=>@project.id, :params=>{:y=>params[:cyear], :m=>params[:cmonth]}
      else
        redirect_to :action=>'meetings', :pid=>@project.id
      end
    
    rescue Exception => exc
        flash[:title] = params[:title]
        flash[:day] = params[:day]
        flash[:month] = params[:month]
        flash[:year] = params[:year]
        flash[:hour] = params[:datehour]
        flash[:minute] = params[:dateminute]
        flash[:ampm] = params[:dateampm]

        if exc.to_s != "errors" then
          message = {"project_error"=>exc.to_s}
        end

        r_msg message
        redirect_to :action=>'schedule_new_meeting', :pid=>@project.id
    end
  end


  def edit_meeting
    @project_meeting = ProjectMeeting.find(params[:meeting_id]) rescue @project_meeting=nil
  end

  def commit_edit_meeting
  
    message=nil
  
    tz = TZInfo::Timezone.get(@project.klass.school.time_zone)
    
    begin
    
      if params[:day] == nil || params[:month] == nil || params[:year] == nil then
        message = {"project_error"=>"Meeting date incorrect."}
      end
 
 
      if params[:year].to_i < tz.utc_to_local(Time.now.utc).year then#Time.now.year then
        message = {"project_error"=>"The meeting date must be equal to or later than today's date!"}
      elsif params[:year].to_i == tz.utc_to_local(Time.now.utc).year then#Time.now.year then
        if params[:month].to_i < tz.utc_to_local(Time.now.utc).month then#Time.now.month then
          message = {"project_error"=>"The meeting date must be equal to or later than today's date!"}
        elsif params[:month].to_i == tz.utc_to_local(Time.now.utc).month then#Time.now.month then 
          if params[:day].to_i < tz.utc_to_local(Time.now.utc).day then#Time.now.day then
            message = {"project_error"=>"The meeting date must be equal to or later than today's date!"}
          end
        end
      end      
            
      if params[:members] != nil then
        if params[:members].length == 0 then
          message = {"project_error"=>"There must be at least one participant for a meeting"}        
        end
      else
        message = {"project_error"=>"There must be at least one participant for a meeting"}
      end

      if message != nil then raise "errors" end
    
      #assemble date
      if params[:ampm]=="pm" then
        hour = params[:hour].to_i + 12
      else
        hour = params[:hour].to_i
      end
      dt = DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i, hour, params[:minute].to_i,0)
      md = tz.local_to_utc(dt)
      meeting_date = md#Time.utc(params[:year], params[:month], params[:day], params[:hour], params[:minute],0,0)

      ProjectMeetingParticipant.transaction do
        ProjectMeeting.transaction do
          @project_meeting = ProjectMeeting.update(params[:meeting_id], {:title=>params[:title], :scheduled_on=>meeting_date})
          if @project_meeting.valid? == true then
            @project_meeting.project_meeting_participants.each do |p|
              p.destroy
            end
  
            ProjectMeetingParticipant.destroy_all ['project_meeting_id=?',@project_meeting.id]

            params[:members].each do |m|
              @project_meeting_participant = ProjectMeetingParticipant.create(:project_meeting_id=>@project_meeting.id, :participant_id=>m)
            end
          else
            message = @project_meeting.errors
            raise "errors"
          end
        end
      end
      message = {"project_error"=>"meeting successfully edited", :type=>"success"}
      
      r_msg message
  
      redirect_to :action=>'meetings', :pid=>@project.id
    
    rescue Exception => exc
        flash[:title] = params[:title]
        flash[:day] = params[:day]
        flash[:month] = params[:month]
        flash[:year] = params[:year]
        flash[:hour] = params[:datehour]
        flash[:minute] = params[:dateminute]
        flash[:ampm] = params[:dateampm]

        if exc.to_s != "errors" then
          message = {"project_error"=>exc.to_s}
        end

        r_msg message
        redirect_to :action=>'schedule_new_meeting', :pid=>@project.id
    end
  end

  def unschedule_meeting
    begin
      ProjectMeeting.transaction do
        ProjectMeetingParticipant.transaction do
          ProjectMeetingNote.transaction do
            ProjectMeetingParticipant.destroy_all "project_meeting_id=#{params[:meeting_id]}"
            ProjectMeetingNote.destroy_all "project_meeting_id=#{params[:meeting_id]}"
            ProjectMeeting.destroy(params[:meeting_id])
          end
        end
      end
      message={"project_error"=>"Meeting successfully unscheduled", :type=>"success"}
      r_msg message
      redirect_to :action=>"meetings", :pid=>@project.id
    rescue Exception => exc
      message={"project_error"=>exc.to_s}
      r_msg message
      redirect_to :action=>"meetings", :pid=>@project.id
    end
  end

  def add_note
  end

  def commit_add_note
    message = nil
    begin
      @project_meeting_note = ProjectMeetingNote.create(:project_meeting_id=>params[:meeting_id], :message=>params[:message])
      if @project_meeting_note.valid? == false then
        message = @project_meeting_note.errors
        raise "errors"
      end
      message={"project_error"=>"Note successfully created", :type=>"success"}
      r_msg message
      redirect_to :action=>"meetings", :pid=>@project.id
    rescue Exception => exc
      if exc.to_s != "errors" then
        message={"project_error"=>exc.to_s}
      end
      r_msg message
      redirect_to :action=>"add_note", :pid=>@project.id, :meeting_id=>params[:meeting_id]
    end
  end

  def delete_note
    begin
      ProjectMeetingNote.delete(params[:note_id])
      message={"project_error"=>"Note successfully deleted",:type=>"success"}
      r_msg message
      redirect_to :action=>"meetings", :pid=>@project.id
    rescue Exception => exc
      message={"project_error"=>exc.to_s}
      r_msg message
      redirect_to :action=>"meetings", :pid=>@project.id
    end
  end

  #################################################################################
  # Tasks Methods
  #################################################################################

  def tasks

  end

  def assign_new_task
    @memberlist = ProjectMember.find(:all, :conditions=>['project_id=?',@project.id]) rescue @memberlist = []

    if params[:fromcalendar] != nil then
      flash[:startyear] = params[:startyear]
      flash[:startmonth] = params[:startmonth]
      flash[:startday] = params[:startday]
      flash[:year] = params[:year]
      flash[:month] = params[:month]
      flash[:day] = params[:day]
    end

  end

  def commit_assign_new_task

    message = nil

    begin
    
      if params[:day] == nil || params[:month] == nil || params[:year] == nil then
        message = {"project_error"=>"Completion date incorrect."}
      elsif params[:startday] == nil || params[:startmonth] == nil || params[:startyear] == nil then
        message = {"project_error"=>"Start date incorrect."}
      end
  
      if params[:startyear].to_i < Time.now.year then
        message = {"project_error"=>"The start date must be equal to or later than today's date!"}
      else 
        if params[:startmonth].to_i < Time.now.month then
          message = {"project_error"=>"The start date must be equal to or later than today's date!"}
        elsif params[:startmonth].to_i == Time.now.month then 
          if params[:startday].to_i < Time.now.day then
            message = {"project_error"=>"The start date must be equal to or later than today's date!"}
          end
        end
      end
  
      if params[:year].to_i < Time.now.year then
          message = {"project_error"=>"The completion date must be equal to or later than today's date!"}
        if params[:month].to_i < Time.now.month then
            message = {"project_error"=>"The completion date must be equal to or later than today's date!"}
        elsif params[:month].to_i == Time.now.month then 
          if params[:day].to_i < Time.now.day then
            message = {"project_error"=>"The completion date must be equal to or later than today's date!"}
          end
        end
      end
        
      if params[:year].to_i < params[:startyear].to_i then
          message = {"project_error"=>"The completion date must be equal to or later than the start date!"}
      else
        if params[:month].to_i < params[:startmonth].to_i && params[:year].to_i <= params[:startyear].to_i then
            message = {"project_error"=>"The completion date must be equal to or later than the start date!"}
        else
          if params[:day].to_i < params[:startday].to_i && params[:month].to_i <= params[:startmonth].to_i && params[:year].to_i <= params[:startyear].to_i then
            message = {"project_error"=>"The completion date must be equal to or later than the start date!"}
          end            
        end
      end
      
      if params[:members] != nil then
        if params[:members].length == 0 then
          message = {"project_error"=>"There must be at least one assignee for a task"}        
        end
      else
        message = {"project_error"=>"There must be at least one assignee for a task"}
      end

      if message != nil then raise "errors" end
    
      #assemble date


      sd = TZInfo::Timezone.get(@project.klass.school.time_zone.to_s).local_to_utc(DateTime.new(params[:startyear].to_i, params[:startmonth].to_i, params[:startday].to_i))
      cd = TZInfo::Timezone.get(@project.klass.school.time_zone.to_s).local_to_utc(DateTime.new(params[:year].to_i, params[:month].to_i, params[:day].to_i))

      start_date = sd#Time.utc(params[:startyear], params[:startmonth], params[:startday], 0,0,0,0)
      completion_date = cd#Time.utc(params[:year], params[:month], params[:day], 0,0,0,0)

    

      


      ProjectTaskAssignee.transaction do
        ProjectTask.transaction do
          @project_task = ProjectTask.create(:project_id=>@project.id, :title=>params[:title], :start_date=>start_date, :completion_date=>completion_date, :task_assigner=>@me.id)
          if @project_task.valid? == true then
            params[:members].each do |m|
              @project_task_assignee = ProjectTaskAssignee.create(:project_task_id=>@project_task.id, :assignee_id=>m)
            end
          else
            message = @project_task.errors
            raise "errors"
          end
        end
      end
      message = {"project_error"=>"task successfully assigned", :type=>"success"}
      
      r_msg message
  
      if params[:fromcalendar] != nil && params[:fromcalendar] != "" then
        redirect_to :action=>'calendar', :pid=>@project.id, :params=>{:y=>params[:cyear], :m=>params[:cmonth]}
      else
        redirect_to :action=>'tasks', :pid=>@project.id
      end
    
    rescue Exception => exc
        flash[:title] = params[:title]
        flash[:startday] = params[:startday]
        flash[:startmonth] = params[:startmonth]
        flash[:startyear] = params[:startyear]
        flash[:day] = params[:day]
        flash[:month] = params[:month]
        flash[:year] = params[:year]

        if exc.to_s != "errors" then
          message = {"project_error"=>exc.to_s}
        end

        r_msg message
        redirect_to :action=>'assign_new_task', :pid=>@project.id
    end
    
  end


  def remove_task
    message=nil
    begin
      ProjectTask.transaction do
        ProjectTaskAssignee.transaction do
          @project_task = ProjectTask.find(params[:task_id])
          @project_task.project_task_assignees.each do |a|
            a.destroy
          end
          @project_task.destroy
          message = {"project_error"=>"Task removed successfully", :type=>"success"}
          r_msg message
          redirect_to :action=>'tasks', :pid=>@project.id
        end
      end
    rescue Exception => exc
      message = {"project_error"=>exc.to_s}
      r_msg message
      redirect_to :action=>'tasks', :pid=>@project.id
    end


  end









  #################################################################################
  # Calendar Methods
  #################################################################################

  #subsection main page
  def calendar
  
    @specified_year = params[:y].to_i
    @specified_month = params[:m].to_i
    @meetings = nil#@project.project_meetings

  end






  
  
  #################################################################################
  # Documents Methods
  #################################################################################

  #subsection main page 
  def documents
    filepath = "shared/project_documents/#{@project.id}"

    if params[:folder] == nil then
      @current_folder = ProjectFolder.find(:first, :conditions=>["project_id=? and folder=?",@project.id, "general"])
    else
      @current_folder = ProjectFolder.find(:first, :conditions=>["project_id=? and guid=?",@project.id, params[:folder]])
    end

    if FileTest.exists?("#{filepath}") then
      
      @directories = @project.project_folders
      @files = ProjectFolder.find(:first,:conditions=>["project_id=? and guid=?",@project.id, @current_folder.guid]).files
    end
    
  end

  def upload_new_document
    filepath = "shared/project_documents/#{@project.id}"
    if FileTest.exists?("#{filepath}") then
      @directories = @project.project_folders
    end
    render_p 'project/upload_new_document'
  end


  def upload_document
    message = nil  
    @documents = params[:documents]
    @comments = params[:comments]

    begin
      DocumentFile.check @documents    
    rescue UnSupportedDocument
      message = {"project_error"=>"document not supported"}
      r_msg message
      redirect_to :action=>"documents", :pid=>@project.id, :folder=>params[:folder]
      return
    rescue Exception => exc
      message = {"project_error"=>exc}
      r_msg message
      redirect_to :action=>"documents", :pid=>@project.id, :folder=>params[:folder]
      return
    end

    begin
      counter=0;
 
      if @documents.length == 0 then 
        message = {"project_error"=>"no documents selected for upload"}
        r_msg message
        redirect_to :action=>"documents", :pid=>@project.id, :folder=>params[:folder]
        return
      end

      #find folder for this upload
      @folder = ProjectFolder.find(:first, :conditions=>["project_id=? and guid=?",@project.id,params[:folder]]) rescue @folder = nil

      @documents.each do |d|
        if d != "" then 
          returned_array = @folder.store(@documents[counter], @comments[counter], @project.id)
          message = returned_array[1]
          counter += 1
          if returned_array[0] == false then
            raise "errors"
          end
        end
      end
      r_msg message
      redirect_to :action=>"documents", :pid=>@project.id, :folder=>params[:folder]
        
    rescue Exception => exc
      r_msg message
      redirect_to :action=>"documents", :pid=>@project.id, :folder=>params[:folder]
      return
    end

  end


  def create_new_folder
    render_p 'project/create_new_folder'
  end

  def commit_create_new_folder
    message = nil
    filepath = "shared/project_documents/#{@project.id}"
    begin
    
      if params[:foldername]==nil || params[:foldername]=="" then
        message = {"project_error"=>"Folder name was not provided"}
        raise "errors"
      end

      if params[:foldername] =~ /\W/ then   #checks for only numbers and characters...
        message = {"project_error"=>"Folder name can only have letters and numbers in it, and no spaces"}
        raise "errors"
      end

     
      if !FileTest.exists?("#{filepath}/#{params[:foldername]}") then
        @folder = ProjectFolder.create(:project_id=>@project.id, :folder=>params[:foldername])
        FileUtils.mkdir_p("#{filepath}/#{params[:foldername]}")
        message = {"project_error"=>"Folder created successfully", :type=>"success"}
      else
        message = {"project_error"=>"Folder with that name already exists"}
        raise "errors"
      end
      r_msg message
      redirect_to :action=>'documents', :pid=>@project.id, :folder=>@folder.guid
    rescue Exception => exc
      if exc.to_s != "errors" then 
        message = {"project_error"=>exc.to_s}
      end
      r_msg message
      redirect_to :action=>'documents', :pid=>@project.id
    end

  end


  def delete_document
    message = nil
    begin
      @document = ProjectFolder.find(:first, :conditions=>["project_id=? and guid=?",@project.id, params[:folder]]) rescue nil

      if @document != nil then
        rval = @document.remove(params[:guid])
        if rval[0] == false then
          message = rval[1]#{"project_errors"=>"error in document deletion"}
          raise "errors"
        end
      else
        message = {"project_error"=>"Document could not be found."}
        raise "errors"
      end

      message = {"project_error"=>"Document successfully deleted.", :type=>"success"}

      r_msg message
      redirect_to :action=>'documents', :pid=>@project.id, :folder=>params[:folder]

    rescue Exception => exc
      if exc.to_s != "errors" then 
        message = {"project_error"=>exc.to_s}
      end
      r_msg message
      redirect_to :action=>'documents', :pid=>@project.id, :folder=>params[:folder]
    end
  end

  
  def download_document
    error_hash = Hash.new
    filepath = "shared/project_documents/#{@project.id}"
    begin
    
      @folder = ProjectFolder.find(:first,:conditions=>["guid=?",params[:folder]])

      @file = DocumentFile.find(:first,:conditions=>["guid=?",params[:guid]])
    
      mypath=filepath+"/"+@folder.folder+"/"+@file.file_name
      if FileTest.file?(mypath) then 
        puts "MIME TYPE: "+@file.mime.to_s
        send_file mypath, {:type=>@file.mime.to_s}
      else
        message = {"project_error"=>"File Does Not Exist"}
        raise "errors"
      end 
    rescue Exception => exc
      if exc.to_s != "errors" then 
        message = {"project_error"=>exc.to_s}
      end
    r_msg message
    redirect_to :action=>'documents', :pid=>@project.id, :folder=>params[:folder]

    end
  end


  def delete_folder
    message = nil
    filepath = "shared/project_documents/#{@project.id}"
    begin
    
   
      @folder = ProjectFolder.find(:first,:conditions=>["guid=?",params[:folder]]) rescue @folder = nil

      mypath=filepath+"/"+@folder.folder

      if FileTest.directory?(mypath) then
        ProjectFolder.transaction do
          DocumentFile.transaction do
            @files = DocumentFile.find(:all, :conditions=>["document_guid=?", @folder.guid]) rescue @files = []
            @files.each do |f|
              f.destroy()
            end
            @folder.destroy()
            FileUtils.rm_r(mypath)
          end
        end
      else
        message = {"project_error"=>"Folder Does Not Exist"}
        raise "errors"
      end 
      message = {"project_error"=>"Folder deletion successful", :type=>"success"}
    rescue Exception => exc
      if exc.to_s != "errors" then 
        message = {"project_error"=>"OH SHI...*KOFFGACKBLRGLRF*"}
      end
    end
    r_msg message
    redirect_to :action=>'documents', :pid=>@project.id
  end












  #################################################################################
  # Private Methods
  #################################################################################

  private
    def validate
        @project = Project.find(params[:pid]) rescue @project = nil
        @project_member = ProjectMember.find(:first, :conditions=>["project_id=? and student_id=?", @project.id, @me.id]) rescue @project_member = nil
        if @project == nil then 
          redirect_to :controller=>'my'
        else
          if @project_member == nil && @admin == nil then
            redirect_to :controller=>'my'
          end
        end
    end

end
