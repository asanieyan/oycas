class Course < ActiveRecord::Base
  has_guid_field :uniq=>true   
  
  belongs_to :school
  belongs_to :course_subject  
  
  has_many :course_notes,:order=>"created_on DESC" do 
        def since time
            @notes_since ||= find(:all,:conditions=>["created_on >= ? ",time])
        end  
  end
  has_many :klasses
        
  has_many :klass_enrollments
  has_many :instructors, :through=> :klasses, :select => "DISTINCT instructors.*"
  
  truncate 'description'
  def notes 
    course_notes;
  end
  def self.parse_search_query_for_sql query_str
          search_value = query_str
          course_number = []
          course_name_and_subject = []
          (values = search_value.split(" ")).each do |portion|            
              if portion =~ /\d+/
                  course_number << portion
              else #if portion.size >= 3
                  course_name_and_subject << portion                
             end
          end
          course_number = course_number.join('')
          course_name_and_subject = course_name_and_subject.join('%') 
          return sanitize_sql(course_name_and_subject),sanitize_sql(course_number)
  end
  def klasses_at_current_semester            
      @current_klasses ||= Klass.find(:all,:conditions=>"course_id = #{self.id} AND semester_id = #{self.school.current_semester.id}")

  end
  def student_registered student     
     sql = ["semester_id = " + self.school.current_semester.id.to_s]
     sql << "course_id = " + self.id.to_s
     sql << "student_id = " + student.id.to_s
     KlassEnrollment.find(:first,:conditions=>sql.join(" AND ")).klass rescue nil  
  end
  def has_student? student
    return student_registered(student)
  end
  def credit
      the_credit = self['credit'] || 0
      return the_credit = the_credit.to_i if the_credit.to_i == the_credit    
  end
  def title format=:full
      the_credit = credit
      return self.subject + " " + self.number + "-" + the_credit.to_s + " " + self.name  if format==:full
      return self.subject + " " + self.number + "-" + the_credit.to_s if format==:small
  end
  def full_title;title(:full);end
  def short_title;title(:small);end
  
end
