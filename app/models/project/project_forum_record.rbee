class ProjectForumRecord < ActiveRecord::Base

  validates_presence_of :subject, :message
  def owner
      return Student.find_by_guid(self.poster_id)
  end


end
