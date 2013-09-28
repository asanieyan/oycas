class SchoolMember < ActiveRecord::Base
  belongs_to :school
  belongs_to :student
  has_guid_field
  def self.students_in_same_school? *students
        ids = students.map{|s| s.id}
        return SchoolMember.find_by_sql("SELECT COUNT(student_id)  FROM school_members WHERE student_id IN (#{ids.join(',')}) GROUP BY school_id HAVING COUNT(student_id) =  #{ids.size}").size > 0  
  
  end
end
