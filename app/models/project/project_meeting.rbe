class ProjectMeeting < ActiveRecord::Base






  has_many :project_meeting_participants
  has_many :project_meeting_notes
  belongs_to :project


  def validate

    self.class.send :include,ActionView::Helpers::TagHelper
    self.class.send :include,ActionView::Helpers::TextHelper
    ActionView::Helpers::TextHelper.const_set "VERBOTEN_TAGS", VERBOTEN_TAGS + %w(img object iframe style)

    self.title ||= ""
    self.title = truncate(sanitize(strip_tags(title.strip)),column_for_attribute('title').limit)

    if not self.title.match(/\S/)
      errors.add_to_base('project_error'=>'Please enter a title.')
      return false
    else
      return true
    end

  end



end
