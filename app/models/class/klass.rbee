class Klass < ActiveRecord::Base
     
    belongs_to :semester
    belongs_to :instructor
    belongs_to :course
    belongs_to :school
    has_many :projects
    has_many :klass_schedules
    has_many :notes, :class_name=>"CourseNote"  ,:order=>"created_on DESC"  
    has_many :students,:through=>:klass_enrollments ,:extend=>StudentQuery
    has_many :klass_enrollments , :order=>"created_on DESC" do 
        def last_one
            @last_one ||= find(:first)
        end
    end
    has_many :discussions, :class_name=>"Forum",:finder_sql=>'SELECT * FROM forums WHERE context_guid = #{self.guid} ORDER BY created_on DESC'
    has_guid_field :uniq=>true    
    
    
    before_create :set_division
    
    strip_tags_and_truncate 'room'
    
    def is_current?
      @is_current ||= (self.semester == self.school.current_semester)
    end
    def forum_topics_since time
      @topics ||= Forum.find(:all,:conditions=>["context_guid = #{self.guid} AND created_on > ?",time])      
    end
    def validate        
        self.room.strip!
        self.room = nil if  self.room !~ /\S/
    end 
    def set_division
        div = Klass.count(:conditions=>"semester_id = #{self.semester.id} AND course_id = #{self.course_id}") + 1
        self.division = div        
    end
    def full_title
      self.name + " " + self.course.name
    end
    def teacher;self.instructor;end;
    
    def enroll_student student
      KlassEnrollment.create :klass_id=>self.id,:course_id=>self.course_id,:semester_id=>self.semester_id,
                             :student_id=>student.id,:school_id=>self.school_id
    end
    def news
        
    end
    def set_time days
      days.each do |day,times|
        periods = times.split(",")
        periods.each do |period|
            start,_end = period.split("-")
            raise unless Time.parse(start) < Time.parse(_end)                       
            KlassSchedule.create :klass_id=>self.id,:start_time=>start,
                                 :end_time=>_end,:day_of_week=>day
            end
        end
  
    end
    
    def name        
        begin
            return self.course_subject+" "+self.course_number+"-D"+division.to_s
        rescue Exception=>e       
        
        end       
        return course.subject+" "+course.number+"-D"+division.to_s
    end
    def group_schedules
        time_sets  = Hash.new
        self.klass_schedules.each do |schedule| 
             key = Time.parse(schedule.start_time).strftime("%I:%M %p").downcase.gsub(/^0/,"") + " to " + 
                    Time.parse(schedule.end_time).strftime("%I:%M %p").downcase.gsub(/^0/,"")
             value = schedule.day_of_week
             time_sets[key] = (time_sets[key] || []) + [value]
        end  
        return time_sets    
    
    end
    def student_registered? student
        @reg_query = {} unless @reg_query        
        return @reg_query[student.id] if @reg_query[student.id]                    
        @reg_query[student.id] = if KlassEnrollment.find(:first,:conditions=>"klass_id = #{self.id} AND student_id = #{student.id}")
                                      true
                                 else
                                      false
                                 end
        return @reg_query[student.id]        
    end
    alias has_student? student_registered?
    def student_can_change_room?(student)
        return student_registered?(student)  && is_current?
    end
    alias student_can_change_teacher? student_can_change_room?
    alias student_can_chat? student_can_change_room? 

    def can_student_post_to_forum? student
       return student_registered?(student)  && is_current?
    end   
    def can_student_see_scrap?(student)
      return true;
    end
    def can_student_post_scrap? student
       return student_registered?(student) && is_current?
    end
    def add_teacher email,first_name,last_name
      teacher = Instructor.new(:school_id=>self.school.id,:email_address=>email,:first_name=>first_name,:last_name=>last_name)
      if (teacher.save)
          self.instructor_id = teacher.id
          self.save
          return teacher
      end    
      return nil
    end
    def has_teacher?;self['instructor_id'] != nil;end
    def room_set?;(self['room'] || "").size > 0;end
    def formated_schedule
       time_sets = group_schedules
       group = []
       time_sets.each do |time,day|
           group << day.join(",") + " " + time
       end
       return group
    end
end
