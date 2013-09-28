class School < ActiveRecord::Base
  has_guid_field :uniq=>true 
  belongs_to :network
  has_many :registrations
  has_many :klasses,:class_name=>'Klass' 
  has_many :staffs,:class_name=>"SchoolStaff",:dependent=>:destroy
  has_many :semesters, :dependent=>:destroy  
  has_many :seasons, :dependent=>:destroy
  has_many :instructors,:order=>'email_address ASC',:dependent=>:destroy
#  has_one  :current_semester , :class_name=>'Semester',:conditions=>'school_id = #{self.id} AND __current__ LIKE "y"'
  has_many :courses,:dependent=>:destroy
  has_many :subjects , :class_name=>'CourseSubject',:order=>"code ASC" ,:dependent=>:destroy
  has_and_belongs_to_many :students, :join_table=>'school_members' ,:select=>"students.*" ,
          :extend=>StudentQuery
  
  composed_of :tz, :class_name => 'TZInfo::Timezone', 
              :mapping => %w(time_zone name)
  has_many :discussions, :class_name=>"Forum",:finder_sql=>'SELECT * FROM forums WHERE context_guid = #{self.guid} ORDER BY created_on DESC'
  MaxReg = 7
  RegDeadlineInDaysBeforeSemesterEnd = 0.day
  LogoSizes = %w(30x30 200x200)
  SizeFlags = %w(s l)
  attr_protected :guid,:id,:created_on,:updated_on
  def teachers;self.instructors;end;
  def current_semester 
    @current_semester ||= Semester.find(:first,:conditions=>"school_id = #{self.id} AND __current__ LIKE 'y'")
  end 
  def logo= http_url
    require 'net/http'
    require 'uri' 
    msg = Net::HTTP.get(URI.parse(http_url))
    save_logo(msg)
  end
  def save_logo msg
    (Image.resize_to msg,LogoSizes,:format=>"GIF").each_with_index do |img,i|
        path = File.join(RAILS_ROOT,"/public/shared_images/schools_logos")
        logo_file =  File.join(path,"#{SizeFlags[i]}#{self.guid}.gif")      
        FileUtils.rm_f logo_file 
        FileUtils.mkdir_p(path)
        File.open(logo_file,"wb"){|f| f.write(img)}
      end          
  end
  def logo
      "/shared_images/schools_logos/l" + self.guid.to_s + ".gif"
  end
  def small_logo
     "/shared_images/schools_logos/s" + self.guid.to_s + ".gif"
  end

  def most_active_classes
    @most_active ||= Klass.find(:all,:select=>"distinct klasses.*",:conditions=>"klasses.school_id = #{id}",
                                     :order=>"klass_enrollments.created_on DESC",
                                     :joins=>"join klass_enrollments on klass_id = klasses.id",
                                     :limit=>15
                                     )      
  end
  def current_klasses_for student      
      student.klasses_at(self)
  end
  def domain;self.email_domain;end;
  def is_host_valid? the_domain
      return false if (the_domain || "").size == 0
      return the_domain.downcase.match(/#{self.email_domain.downcase}$/)
  end
  def is_email_valid? email      
      
      self.class.send :include, ApplicationHelper
      return (EmailHelper::valid_format?(email) and is_host_valid?(email))
  end
  def deadline_to_reg     
      return current_semester.end_date.ago(RegDeadlineInDaysBeforeSemesterEnd)      
  end
  def deadline_to_reg_passed?     
      deadline_to_reg <= tz.utc_to_local(Time.now.utc) and false
  end
  def exceeds_max_reg student
      @reg_num ||= KlassEnrollment.count(:all,:conditions=>"school_id = #{self.id} AND student_id = #{student.id} AND semester_id = #{self.current_semester.id}")      
      return @reg_num >= School::MaxReg 
  end
  def student_can_register?(student)     
     !student.is_admin? and not exceeds_max_reg(student) and not deadline_to_reg_passed?
  end
  def has_student? student  
      require 'school/school_member'           
      return true if student.is_admin?       
      @members ||= {}
      @members[student.id] ||= SchoolMember.find(:first,:conditions=>"school_id = #{self.id} AND student_id = #{student.id} AND confirmed LIKE 'y' ").id rescue nil
      return @members[student.id]
  end  
  def can_student_post_to_forum? student    
      return (!student.is_admin? and has_student?(student))
  end
  def can_student_post_scrap? student
      return can_student_post_to_forum?(student)
  end
  def can_student_see_scrap? student
      return can_student_post_scrap?(student)
  end  
  def student_drop_course student,course_id
     KlassEnrollment.delete_all(["student_id = #{student.id} AND semester_id = #{self.current_semester.id} AND course_id = ?",course_id])
  end
  def student_drop_all_courses(student)
      KlassEnrollment.delete_all("student_id = #{student.id} AND semester_id = #{self.current_semester.id}")  
  end  
  def drop_student(student)
      student_drop_all_courses(student)
      SchoolMember.delete_all("school_id = #{self.id} AND student_id = #{student.id} AND default_school IS NULL")
  end
  def news_feed
    @rss_feed ||= begin      
      require 'rss/1.0'
      require 'rss/2.0'
      require 'open-uri'   
      content = "" # raw content of rss feed will be loaded here
      begin
        open(self.rss_news_feed) do |s| content = s.read end
        @rss_feed = RSS::Parser.parse(content, false)     
      rescue
        @rss_feed = nil
      end        
    end
    
  end
  def has_important_dates_set?
    self.current_semester.class_start && self.current_semester.class_end && self.current_semester.exam_end
  end
  def classes_started? 
      return self.current_semester.class_start.to_date <= self.current_time.to_date  
  end
  def first_day_of_classes?
      return self.current_semester.class_start.to_date == self.current_time.to_date  
  end
  def classes_ended?
      return self.current_semester.class_end.to_date < self.current_time.to_date
  end
  def exams_started?
    return classes_ended?
  end
  def exams_ended?     
    ((self.current_semester.exam_end.to_date < self.current_time.to_date)  && exams_started?)
  end
  def class_end
    current_semester.class_end
  end
  def exam_end
    current_semester.exam_end
  end
  def class_start
    current_semester.class_start
  end
  def time time
    tz.utc_to_local(time)
  end
  def current_time
    time Time.now.utc
  end
  def get_current_season
      c_season = nil
      self.seasons.each do |season|
          if season.is_current_season?
            c_season = season
            break;
          end
      end
      return c_season
  end
  def set_new_semester options={}     
      if (self.current_semester.season rescue nil) == get_current_season #same season no semester change
        p "new semester has not started yet"
        p "current semster ends in " + self.current_semester.end_date.to_s        
        return 
      end
      semester = Season.create_new_semester(get_current_season,options)
      if not self.current_semester
        semester.save
      else
        begin
          Semester.transaction do
            self.current_semester.__current__ = nil;
            self.current_semester.save            
            semester.save
          end
        rescue Exception=>e
          p e.message
        end
      end
      @current_semester = nil
      Notifier::deliver_a_message("kim@oycas.com","New semester for #{self.name}","Please set the important dates for #{self.name} for semester #{self.current_semester.name}")
     
   end

  private 
  def before_destroy
      raise if self.students.size > 0
  end
end
