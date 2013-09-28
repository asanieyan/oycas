namespace :promo do
  desc "Creates the 'not registered in any courses' template"
  task :create_template_2 => :environment do
    unregistered_students = Array.new
    students = Student.find :all
    students.each do |student|
      if student.klasses_at(student.school).length == 0 then
        unregistered_students << student
      end
      
    end
  end
end
