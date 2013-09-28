class FriendRequest < ActiveRecord::Base
  belongs_to :requester, :class_name=>'Student', :foreign_key=>'requester_id'
  belongs_to :requestee, :class_name=>'Student', :foreign_key=>'requestee_id'
  
  escape_once_and_truncate 'message'
  def self.find_request_out(requester,requestee)
      find(:first,:conditions=>"requester_id = #{requester.id} AND requestee_id = #{requestee.id}")
  end
#  def before_save
#    self.class.send :include,ActionView::Helpers::TagHelper
#    self.class.send :include,ActionView::Helpers::TextHelper  	        
#    self.message = escape_once(truncate(self.message))
#  end

end
