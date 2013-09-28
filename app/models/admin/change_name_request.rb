class ChangeNameRequest < ActiveRecord::Base
    
    strip_tags 'requested_name'
    belongs_to :student,:foreign_key=>'student_id'
    def self.create student,new_name
     self.delete_all("student_id = #{student.id}")    
     inst = ChangeNameRequest.new(:student_id=>student.id,:requested_name=>new_name)
     inst.save
     return inst
    end
    def validate
       if not Student.validate_name(requested_name)
          errors.add('requested_name',"Please enter your full name.")        
       end
    end
    
end
