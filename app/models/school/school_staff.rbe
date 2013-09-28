class SchoolStaff < ActiveRecord::Base
  def self.add_entry school_id,email,justification
      begin
        SchoolStaff.create :school_id => school_id,:email_address => email,:entry_justification=>justification
      rescue
      
      end    
  end
end
