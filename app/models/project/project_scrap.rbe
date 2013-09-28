class ProjectScrap < ActiveRecord::Base
  validates_length_of :message, :maximum => 400, :message => "Message too long - max 400 characters" 
  validates_length_of :message, :minimum => 1, :message => "No valid message provided" 
  validates_presence_of :message, :message => "Message required, none found" 

end
