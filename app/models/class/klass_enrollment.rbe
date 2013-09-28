class KlassEnrollment < ActiveRecord::Base
    belongs_to :student
    belongs_to :semester
    belongs_to :klass
    belongs_to :course

    def self.students_are_classmates? *students
        ids = students.map{|s| s.id}
        return KlassEnrollment.find_by_sql("SELECT COUNT(student_id)  FROM klass_enrollments WHERE student_id IN (#{ids.join(',')}) GROUP BY klass_id HAVING COUNT(student_id) =  #{ids.size}").size > 0
    end                             
end
