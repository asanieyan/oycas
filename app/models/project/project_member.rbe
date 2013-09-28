class ProjectMember < ActiveRecord::Base
  belongs_to :project

  def self.students_are_teammates? *students
        ids = students.map{|s| s.id}
        return ProjectMember.find_by_sql("SELECT COUNT(student_id)  FROM project_members WHERE student_id IN (#{ids.join(',')}) GROUP BY project_id HAVING COUNT(student_id) =  #{ids.size}").size > 0
  end

  def destroy
    if self.project.project_members.size == 1
        self.project.destroy
    end
  
  end


end
