class Scrap < ActiveRecord::Base
  belongs_to :sender,:class_name=>'Student',:foreign_key=>'sender_id'
  
  escape_once_and_truncate 'message'
  validates_presence_of :message
  
end
