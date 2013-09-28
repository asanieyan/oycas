class Notifier < ActionMailer::Base   
   Host =  ENV['RAILS_ENV'] == "production" ? "http://www.oycas.com"  : "http://dev.oycas.com:3000" 
   def a_message to,subject,msg_body
     @recipients = to
     @from       = "info@oycas.com" 
     @subject    = subject     
     @body =  {'msg_body'=>msg_body}      
   end
   def invite_to_oycas(inviter,reciever)
     @recipients = reciever
     @from       = "join-oycas-now@oycas.com"
     @subject    = "#{inviter.full_name} has invited you to oycas"
     @content_type = "text/html"
     @body =  {'inviter'=>inviter}    
   end
   def new_note_created note,klass,recipient
        @recipients = recipient.emails.default.address
        @from = "new-class-note@oycas.com"
        @subject = "#{klass.name} New Note - #{note.title}" 
        @body = {'note'=>note,'klass'=>klass}     
   end
   def new_topic_created klass,discussion,recipient
        @recipients = recipient.emails.default.address
        @from = "new-class-discussion@oycas.com"
        @subject = "#{klass.name} New Discussion - #{discussion.topic}" 
        @body = {'discussion'=>discussion}
   end
   def new_topic_created klass,discussion,recipient
        @recipients = recipient.emails.default.address
        @from = "new-class-discussion@oycas.com"
        @subject = "#{klass.name} New Discussion - #{discussion.topic}" 
        @body = {'discussion'=>discussion,'klass'=>klass}
   end
   def report_bug student,report,browser
        @recipients = "bugs@oycas.com"
        @from = student.username
        @subject = "Oycas Bugs" 
        @body = {'student'=>student,'report'=>report,'browser'=>browser} 
   end
   def invite_to_register inviter,klass,reg_link,emails
        @recipients = emails.pop
        @bcc  = emails
        @from = klass.course.subject.downcase + klass.course.number.downcase + "@oycas.com"
        @subject = "Register in #{klass.course.full_title}"
        @body = {'inviter'=>inviter,'klass'=>klass,'reg_link'=>reg_link}
   
   end
   def classified_reply(inquirer,post,inquirer_email,subject,message)
        @recipients = post.owner.emails.default.address
        @from = "classifieds@oycas.com"
        @subject = "Oycas Classifieds - #{subject || ''}" 
        @body = {'reply_message'=>message,'inquirer'=>inquirer,'post'=>post,'email'=>inquirer_email}
    
   end
   def friend_request(requester,requestee)
     @recipients = requestee.emails.default.address
     @from       = "friend-request@oycas.com"
     @subject    = "#{requester.full_name} has added you as a friend on Oycas !"
     @body =  {'requester'=>requester,'requestee'=>requestee}
   
   end
   def private_message_notifier(sender,reciever,subject,body)
     @recipients = reciever.emails.default.address
     @from       = "no-reply@oycas.com"
     @subject    = "Oycas Private Message - #{subject}"
     @content_type = "text/html"
     @body =  {'pbody'=>body,'sender'=>sender,'reciever'=>reciever}        
   end
   def reset_password(student,link)
     @recipients = student.username
     @from       = "resetpassword@oycas.com"
     @subject    = "Oycas - Please Reset Your Password Now"
     @body = {'student'=>student,'link'=>link}
           
   end
   def signup_notification(reg)
     @recipients = reg.email
     @from       = "welcome@oycas.com"
     @subject    = "Please Acctivate Your Account Now"
     @body['reg']=  reg
     
   end
   def confirm_email(email,student)
        @recipients = email.address
        @from       = "regemail@oycas.com"
        @subject    = "Oycas - Please Acctivate Your New Contact Email Now"
        @body = {'email'=>email,'student'=>student}
   end
   def confirm_school(membership,school,student)
        @recipients = membership.registered_email
        @from       = "regschool@oycas.com"
        @subject    = "Please Acctivate Your Account Now"
        @body = {'membership'=>membership,'school'=>school,'student'=>student}
   end        
   
   def confirm_admin(new_admin)
      @recipients = new_admin.email
      @from = "admin@oycas.com"
      @subject = "Confirm to be a new admin"
      @body = {'new_admin'=>new_admin}
   end  

   def violation_notification(reported_student,subject,msg) 
       raise unless subject and msg
       @recipients = reported_student.emails.default.address
       @from = "admin@oycas.com"
       @subject = "Oycas - " + subject
       @body = {'msg'=>msg}
   end 
end
