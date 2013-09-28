class ProjectTask < ActiveRecord::Base



  belongs_to :project
  
  has_many :project_task_assignees



  def validate

    self.class.send :include,ActionView::Helpers::TagHelper
    self.class.send :include,ActionView::Helpers::TextHelper
    ActionView::Helpers::TextHelper.const_set "VERBOTEN_TAGS", VERBOTEN_TAGS + %w(img object iframe style)

    self.title ||= ""
    self.title = truncate(sanitize(strip_tags(title.strip)),column_for_attribute('title').limit)
#
#    self.description ||= ""
#    self.description = truncate(sanitize(strip_tags(description.strip)),column_for_attribute('description').limit)
#
    if not self.title.match(/\S/)
      errors.add_to_base('project_error'=>'Please enter a title.')
      return false
    else
      return true
    end

  end










#  validates_presence_of :title, :message => "Title required, none found" 
#  validates_presence_of :completion_date, :message => "Completion date required, none found" 
#
#  #################################################################################
#  # Create/Destroy Methods
#  #################################################################################
#
#  def add_assignees(assignees=nil)
#    error_hash = Hash.new
#    begin
#      ProjectTaskAssignee.transaction do
#        assignees.each do |assignee|
#
#          new_assignee = ProjectTaskAssignee.create(
#            :id=>nil,
#            :project_guid=>self.project_guid,
#            :task_id=>self.id,
#            :guid=>assignee
#          )
#          if new_assignee.errors.length > 0 then
#            new_assignee.errors.each do |key, value|
#              error_hash[key] = value
#            end
#          end 
#
#          if error_hash.length > 0 then
#            raise "errors" 
#          end 
#        end
#      end    
#        return nil
#    rescue Exception => exc
#      if exc.to_s != "errors" then
#        error_hash['exception'] = exc
#      end
#      return error_hash
#    end
#  end
# 
#  def remove
#    error_hash = Hash.new
#    begin
#      ProjectTaskAssignee.transaction do
#        ProjectTaskAssignee.delete_all(["task_id=?",self.id])
#        ProjectTask.delete(self.id)
#      end
#      return nil
#    rescue Exception => exc
#      return error_hash['exception'] = exc
#    end
#  end
# 
#  #################################################################################
#  # Helper Methods
#  #################################################################################
#
#
#  def assignees
#    a = ProjectTaskAssignee.find(:all, :conditions=>["task_id=? and project_guid=?",self.id, self.project_guid]) rescue a = nil
#    return a
#  end


end
