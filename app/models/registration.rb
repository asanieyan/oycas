class Registration < ActiveRecord::Base
  has_guid_field
  def before_save
      self.random_number = rand(999999999)
  end
  validates_confirmation_of :password,:message => "Password should match confirmation"
  def validate    
      errors.add('password',"Your password must be at least #{Student::PasswordLength} characters long.") if ((password || "").size < Student::PasswordLength)
      errors.add('name',"Please enter your full name.") if not Student.validate_name(name)
  end  
end
