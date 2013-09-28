class KlassController < ApplicationController
  before_filter :validate,:except=>"suggest_room suggest_instructor"  
  verify :flash=>:member_of_class, :method=>'post',:only=>%w(invite_to_register set_teacher set_room)  

  
  include Note
  include Scrapalious 
  include Forums
  include StudentDisplay
  include News

  def render_menus
    home = add_menu("Class Home",{:action=>'main'})
      home.add_sub_menu '#{@klass.school.short_name} Home','#{url_for_school(@klass.school)}'
    discussion = add_menu "Discussions",{:action=>'forum_topics'}
      discussion.add_sub_menu 'Start New Topic',{:action=>'new_forum_topic',:if=>"@klass.can_student_post_to_forum?(@me)"}
    add_menu 'Class Binder',{:action=>'show_notes'}
    #add_menu("My Courses",{:depends_on_sub=>true},nil,MyHelper::render_course_items)      
  end


  
  
  add_news_for "@klass","@klass.guid","@klass.course.guid"
  add_student_display_methods "@klass","@klass.students","class student"
  add_note_methods_for "@klass"
  add_forum_methods "@klass"
  add_scrap_methods "@klass"
  
  alias classmates students_in_full
  alias rate_classmates rate_students
  def students_in_full; redirect_to :action=>'classmates';end;
  def rate_students; redirect_to :action=>'rate_classmates';end;
  public
  def suggest_instructor
    begin
      school = School.find(params[:s])
      
    rescue
      render :nothing=>true
    end
  end
  def suggest_room
      @klasses = Klass.find(:all,:select=>"distinct klasses.room",:conditions=>["school_id = ? AND room IS NOT NULL AND room like ? ",params[:s],params[:value] + '%'])           
      p @klasses
      render_p 'shared/render_auto_completer',{'results'=>@klasses.map{|k| k.room},'value'=>params[:value]}
  end
  def get_room
    if request.xml_http_request?
      render :text=>(@klass.room || "")
    end
  end
  def set_room
    if request.xml_http_request?
          @klass.room = params[:value]
          @klass.save
          #redirect_to :back
          render :text=>(@klass.room || "")
          return
    end    
  end
#  def fetch(uri_str, limit = 10)
#    # You should choose better exception.
#
#    raise ArgumentError, 'HTTP redirect too deep' if limit == 0
#      url = URI.parse(uri_str)
#      response = Net::HTTP.start(url.host, url.port) {|http|
#              gab_path =  url.path + "?" + url.query
#              req = Net::HTTP::Get.new(gab_path)
#              req['User-Agent'] = 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.3) Gecko/20070309 Firefox/2.0.0.3'                
#              req['Cookie'] = "joinLeavePref=1; __qca=462afe81-e4ff4-797b8-671f2; __utma=126925339.307410387.1177222787.1178185383.1178203924.49; __utmz=126925339.1178203924.49.49.utmccn=(referral)|utmcsr=localhost:3000|utmcct=/class/693843660315061331/main|utmcmd=referral; audioPref=1; __utmc=126925339; __qcb=1221853948; __utmb=126925339; JSESSIONID=8C97889E5245F9C7EFB835C561A83797"                                                
#              http.request(req)
#      }
#    
#      if  response.is_a? Net::HTTPFound
#         fetch(response['location'], limit - 1)
#      elsif response.is_a? Net::HTTPSuccess
#        response
#      else
#        response.error!
#      end
#  end  
#  def parse_gabbly
#           require 'net/http'
#           require 'uri'  
#           gab_path =  "http://cw.gabbly.com/gabbly/cw.jsp?" + URI.escape("e=1&dnc=true&nick=#{@my.full_name}&t=#{params[:t]}")  
#           @m = fetch(gab_path)   
#           render :inline=>"<%= @m.body.gsub('/gabbly/','http://50978640.gabbly.com/gabbly/').gsub('images/','http://50978640.gabbly.com/gabbly/images/')%>"
#    
#  end
  def save_klass_note documents
  
      redirect_to :back
  end
  def invite_to_register
      if not params[:commit]
        render_p 'invite_to_register'
      else
        emails = (params[:emails] || "").gsub(/\s+/,' ').split(" ").uniq[0..20].select{|e| EmailHelper::valid_format?(e)}          
        if emails.size > 0           
          Notifier::deliver_invite_to_register(@me,@klass,"/class/#{@klass.guid}/main",emails.clone)
        end        
        render :update do |p|
          if emails.size == 0
            p.message.show({'invite_error'=>"Please enter at least one valid email address."})  
          else
            p.redirect_to :action=>:main
          end
        end
        return
      end
  end
  def set_teacher      
      if request.post? and not request.xml_http_request?
        begin
          if params[:teacher_id]
              new_teacher = Instructor.find(params[:teacher_id])                 
              raise unless new_teacher.school.id == @klass.school.id #can only set instructors from this school
              old_teacher = @klass.instructor              
              @klass.instructor_id = new_teacher.id
              @klass.save
              create_news_for_class_teacher(@klass,old_teacher,new_teacher)              
          end
        rescue Exception=>e 
        end
        redirect_to :back
        return          
      
      end
      if @klass.school.instructors.empty?          
          render :update do |page|
              page.redirect_to :action=>'add_new'
          end
          response.headers['Status'] = "300 Found"
          return
      end
      render_p 'klass/set_teacher'
  end
  def main
    render :template=>'klass/main'
  end
  def index
    render :action=>"main"
  end
  def flash_image
      flash.keep(:image)
      send_data flash[:image],{:disposition =>'inline'}  
  end  
  def add_new          
      flash.keep(:image)
      flash.keep(:suggested_teachers)
      begin        
        @school = @klass.school                
        raise "Not registered in class" unless @school.has_student?(@me) and @klass.has_student?(@me)
        @teacher = Instructor.find(:first,:conditions=>["school_id = #{@school.id} AND id = ?" ,params[:teacher_id]]) if params[:teacher_id]

#        if @teacher and @teacher.locked
#            render :nothing=>true
#            return            
#        end
        if request.post?            
            if @teacher
              @teacher.save_info(params[:first_name].strip,params[:last_name].strip) 
              old_teacher = @klass.instructor
              @klass.instructor_id = @teacher.id;@klass.save;
              create_news_for_class_teacher(@klass,old_teacher,@teacher)            
            else              
              raise ArgumentError,"Invalid email for #{@school.name}. Please enter a valid email address" unless @school.is_email_valid? params[:email]                       
              email_username = params[:email].match(/(.*?)@/)[1].to_s.strip                        
              @teacher = Instructor.find(:first,
                  :conditions=>["school_id = #{@klass.school_id} AND email_address LIKE ?",
                                email_username + '@%']) 
              if not @teacher
                patterns = []#["email_address LIKE '%#{email_username}%'"]
                email_username.size.times  do |i|                                 
                      patterns << "email_address RLIKE '#{email_username.sub(/(.{#{i}})(.)/,'\1\2?')}'" 
                      patterns << "email_address RLIKE '#{email_username.sub(/(.{#{i}})(.)/,'\1\2.?')}'" 
                      patterns << "email_address RLIKE '#{email_username.sub(/(.{#{i}})(.)/,'\1\2.?.?')}'" 
                end
                patterns = patterns.join(" OR ")                
                @suggestive_teachers = Instructor.find(:all,
                    :conditions=>"school_id = #{@klass.school_id} AND #{patterns}")
                
              end            
              if @teacher
                  r_msg :msg2=>"This instructor already exists",:type=>"alert"
                  redirect_to params.update(:teacher_id=>@teacher.id)
                  return
              elsif not @suggestive_teachers.empty?
                  flash[:suggested_teachers] = @suggestive_teachers.map{|t| t.id}
                  flash[:email] = params[:email]
                  flash[:name] = "#{params[:first_name]} #{params[:last_name]}"
                  redirect_to :back
                  return
              end
#              raise ArgumentError, "test"
              old_teacher = @klass.instructor
              @teacher = @klass.add_teacher(params[:email].strip,params[:first_name].strip,params[:last_name].strip)
              create_news_for_class_teacher(@klass,old_teacher,@teacher)
              
            end            
            @teacher.profile_img = flash[:image] if flash[:image] and @teacher and !@teacher.has_profile_image?
            redirect_to klass_url(:cid=>@klass.guid)
            return
        end
      rescue ArgumentError=>e
         r_msg :msg2=>[(e.message rescue nil),(teacher.errors rescue nil)].compact
        
         flash[:name] = "#{params[:first_name]} #{params[:last_name]}"         
         redirect_to :back
         return
      rescue Exception=>e 
#        p e.message
        redirect_to :controller=>'my'
        return
      end 
      @suggestive_teachers = Instructor.find(flash[:suggested_teachers])if flash[:suggested_teachers] and not @teacher
      unless @teacher
        @teacher = Instructor.new 
        @teacher.first_name,@teacher.last_name = flash[:name].split(" ",2) rescue ["",""]
        @teacher.email_address =  flash[:email]
      end

      
      render :template=>'instructor/add_new'                 
      
  end
  alias edit add_new  
  def show_documents
        render :template=>'documents/show_documents'
  
  end

  private 
    def new_topic_created forum_topic
       MiddleMan.new_worker(:class => :notify_mailer_worker,
                       :args =>[:new_class_discussion,@klass.id,forum_topic.id ]).delete rescue nil       
    end  
    def validate
       if params[:class_name]                    
          div_num = params[:division]
          code = params[:class_name]     
          @klass = Klass.find(:first,:select=>"klasses.*",:joins=>"JOIN courses ON courses.id = course_id",:conditions=>"CONCAT(courses.subject,courses.number) LIKE '#{code}' AND division = #{div_num} ") 
          if @klass
	          redirect_to klass_url(:cid=>@klass.guid) rescue nil
		  else
		  	  redirect_to "/my/home"
		  end          
		  return 
       else
          @klass = Klass.find_by_guid(params[:cid])
       end
       unless @klass and (@school = @klass.school).has_student?(@me)         
          redirect_to :controller=>"my"
          return false
       end
       flash[:member_of_class] = true if @klass.has_student?(@me) and @klass.is_current?
       if @admin != nil then  
        return true
       end

     end
end
