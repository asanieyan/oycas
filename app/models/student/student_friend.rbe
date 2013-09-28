class StudentFriend < ActiveRecord::Base
  belongs_to :student
  

  def self.students_are_friends?(student1,student2)
      StudentFriend.find(:first,:conditions=>"student_id = #{student1.id} AND friend_id = #{student2.id}")     
  end
  def self.remove_friendship student1,student2
     StudentFriend.delete_all("student_id IN (#{student1.id},#{student2.id}) AND friend_id IN (#{student1.id},#{student2.id})")  
  end
  def self.add_friendship student1, student2
      begin
        StudentFriend.transaction do 
          rec1 =   StudentFriend.new 'student_id' => student1.id ,'friend_id' => student2.id
          rec2 =  StudentFriend.new 'student_id' => student2.id ,'friend_id' => student1.id
          rec1.save
          rec2.save
        end
      rescue
      
      end  
  end
end
