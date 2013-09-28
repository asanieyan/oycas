class Admin < ActiveRecord::Base
#   composed_of :tz, :class_name => 'TZInfo::Timezone', 
#              :mapping => %w(time_zone name)
   
#   has_many :sent_messages, :class_name=>"IntranetMessage", :foreign_key=>'sender_id', :conditions=>'deleted_by_sender IS NULL', :order=>'created_on DESC'
    has_guid_field :uniq=>true
    def password= passwd  
      if (passwd || "").size <= 8
        errors.add_to_base('password'=>'Your password must be at least 8 characters long')
        return 
      end      
      require 'digest/md5'
      self['password'] =  Digest::MD5.hexdigest(passwd)                         
    end
    def send_message  recipients,subject,body
        recipients = Student.find(:all) if recipients == :all
        s = Student.new
        s['id'] = 0       
        IntranetMessage.deliver_message(s,recipients,subject,body)
    end
    def self.piggy
      s  = Student.new(:first_name=>"Oycas",:last_name=>"Administrator")
      s.time_zone = "Canada/Pacific"
      s.id=0
      s.guid=0
      s.rank = :piggy
      return s      
    end

    def validate
        self.class.send :include,ApplicationHelper
        errors.add_to_base('first_name'=>'Enter a first name for admin') if (first_name || "").size == 0
        errors.add_to_base('last_name'=>'Enter a last name for admin') if (last_name || "").size == 0                
        errors.add_to_base('email'=>"Enter a valid email") unless EmailHelper::valid_format?(email || "")
        
    end
end
