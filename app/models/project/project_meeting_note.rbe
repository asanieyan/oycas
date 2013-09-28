class ProjectMeetingNote < ActiveRecord::Base

  belongs_to :project_meeting

  def validate

    self.class.send :include,ActionView::Helpers::TagHelper
    self.class.send :include,ActionView::Helpers::TextHelper
    ActionView::Helpers::TextHelper.const_set "VERBOTEN_TAGS", VERBOTEN_TAGS + %w(img object iframe style)

    self.message ||= ""
    self.message = truncate(sanitize(strip_tags(message.strip)),column_for_attribute('message').limit)

    if not self.message.match(/\S/)
      errors.add_to_base('project_error'=>'Please enter a message.')
      return false
    else
      return true
    end

  end

end
