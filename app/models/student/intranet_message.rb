class IntranetMessage < ActiveRecord::Base

   belongs_to :student, :class_name=>'Student', :foreign_key =>'sender_id'
   has_many :recievers, :through=>:records
   has_many :records , :class_name=>'IntranetMessageRegistry'

   
   strip_tags_and_truncate 'subject'
   sanitize_html 'body'       
   def self.delete_all ids,sender_id
       IntranetMessage.update_all "deleted_by_sender = 'y'", "id IN (#{ids}) AND sender_id = #{sender_id}" 
   end
   def self.deliver_message  from,recipients,subject,body
          recipients = [recipients] unless recipients.is_a? Array
          raise "Invalid Recipients For Intranet Message" if recipients.empty? or recipients.include?(from)
          message = self.new
          begin
                    IntranetMessage.transaction do
                      IntranetMessageRegistry.transaction do        
                        message = IntranetMessage.create( 
                            :sender_id=>from.id,                             
                            :body=> body,
                            :subject => subject
                        )
                        raise "Error when creating intranet message" unless message.errors.empty?
                        recipients.each do |recipient|
                                IntranetMessageRegistry.create( 
                                                :intranet_message_id => message.id,
                                                :reciever_id => recipient.id                                      
                                              )                
                        end          
                      end
                   end     
         rescue Exception=>e

         end
         return message
   end

   def self.create_sys_msg subject,body
       sm = nil
       IntranetMessage.transaction do 
          IntranetMessageRegistry.transaction do        
              sm = IntranetMessage.create(:sender_id => 0,:subject=>subject,:body=>body)
              students = Student.find(:all)
              students.each do |s|
                    IntranetMessageRegistry.create(:reciever_id=>s.id,
                                        :intranet_message_id=>sm.id)
              end
          end
        end
        return sm              
   end
   def self.find_admin_messages(*args)
        args = [args].flatten
        self.with_scope(:find=>{:conditions=>'sender_id = 0 AND deleted_by_sender IS NULL'}) do
            case args.first
              when :all  then self.find(:all,args)
              when :first then self.find(:first,args)
              else  self.find(args)
            end
        end
   end
   def sender
      if self.sender_id != 0
        return self.student
      else
        return Admin.piggy
      end
   end  
#   def folder= folder
#      self['folder'] = folder
#   end
   def folder
      self['folder'] ? self['folder'] : 'si'
   end
   def is_read
      folder != 'si' ? self['is_read'] : :y
   end
   def sys_msg?
      sender_id == 0
   end  
   def validate             
       self.body ||= ""
       self.subject ||= ""
       self.subject.gsub!(/\s/,' ')      
       self.subject = nil if self.subject !~ /\S/
  
       self.body = "" if ActiveRecordTextHelper::strip_tags(self.body) !~ /\S/

       if (subject || "").size > size_of('subject')
          errors.add(:subject,"Subject is too long")
       end
       if body.size > 65535
           errors.add(:body,"The body of the message must be less than 65535 characters.")
       elsif body.size == 0
           errors.add(:body,"The body of the message may not be empty.")
       end
    
        
   end   
end

