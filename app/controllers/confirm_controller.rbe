class ConfirmController < ApplicationController
    private
    def render_invalid_link        
        render :template=>'confirm/invalid_link'
    end
    public
    def friendship
         begin
           requester = Student.find_by_guid(params[:id])
           req = FriendRequest.find(:first,:conditions=>"requester_id = #{requester.id} AND requestee_id = #{@my.id}")
           raise unless req
           req.destroy
           StudentFriend.add_friendship(requester,@me)
           redirect_to :controller=>'my'
#           redirect_to :controller=>"student",:sid=>requester.guid,:action=>'profile'
         rescue Exception=>e
            render_invalid_link
         end
    
    end
    def new_email
          guid = params[:id]
          if (record = StudentContactEmail.find_by_student_id_and_guid_and_confirmed(@me.id,guid.to_i,nil))
               record.confirmed = 'y'
               @me.default_contact_email= record
               r_msg "email-title"=>"Email has been confirmed.",:type=>'success'
               redirect_to :controller=>'my',:action=>"my_settings"
          else
              render_invalid_link
          end
          return        
    end
    def school
        begin
            membership = SchoolMember.find_by_guid(params[:id]) 
            if membership and membership.student_id == @my.id and not membership.confirmed    
                membership.confirmed = 'y';membership.save; 
                StudentContactEmail.create :student_id => @me.id,:contact_email=>membership.registered_email,
                                              :confirmed =>'y'                                            
            end 
            r_msg 'school-select'=>"Welcome to #{membership.school.name}" ,:type=>'success'           
        rescue
            r_msg 'school-select'=>"Invalid link"
        end   
        redirect_to :controller=>'my',:action=>'my_settings',:t=>'myschools'
    
    end
end



