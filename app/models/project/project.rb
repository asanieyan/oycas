class Project < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  require "project/project_member.rb"
  require "project/project_meeting.rb"
  require "project/project_meeting_note.rb"
  require "project/project_meeting_participant.rb"
  require "project/project_task.rb"
  require "project/project_task_assignee.rb"
  require "project/project_folder.rb"
  has_guid_field :uniq=>true
  

  #require 'project_controller.rb'
  #has_forum "@project.id"

#  include ScrapsFunctionality
#  def myScrapContext
#    return ProjectScrap
#  end

  belongs_to :klass

  has_many :project_members do 
      def beside_me
        @members_beside_me ||= find(:all,:conditions=>"student_id != #{$my.id}")
      end
  end

  has_many :project_tasks
  has_many :project_meetings
  has_many :project_folders


  has_and_belongs_to_many :students, :join_table=>'project_members', :select=>"students.*" 

  def members
    self.project_members
  end
  def validate

    self.class.send :include,ActionView::Helpers::TagHelper
    self.class.send :include,ActionView::Helpers::TextHelper
    ActionView::Helpers::TextHelper.const_set "VERBOTEN_TAGS", VERBOTEN_TAGS + %w(img object iframe style)

    self.title ||= ""
    self.title = truncate(sanitize(strip_tags(title.strip)),column_for_attribute('title').limit)

    self.description ||= ""
    self.description = truncate(sanitize(strip_tags(description.strip)),column_for_attribute('description').limit)

    if not self.title.match(/\S/)
      errors.add_to_base('project_error'=>'Please enter a title.')
      return false
    else
      return true
    end

  end


  def destroy
  message = nil
    begin 
              #delete project here
              Forum.transaction do
              Scrap.transaction do
              Project.transaction do
                ProjectMember.transaction do
                  ProjectMeeting.transaction do
                    ProjectMeetingNote.transaction do
                      ProjectMeetingParticipant.transaction do
                        ProjectTask.transaction do
                          ProjectTaskAssignee.transaction do
                            ProjectFolder.transaction do
                            DocumentFile.transaction do
                              
                              Scrap.destroy_all ["reciever_guid=?",self.guid]

                              self.project_tasks.each do |t|
                                t.project_task_assignees.each do |a|
                                  a.destroy
                                end
                                t.destroy
                              end
                             
                              
                              self.project_meetings.each do |t|

                                t.project_meeting_participants.each do |p|
                                  p.destroy
                                end
  
                                t.project_meeting_notes.each do |n|
                                  n.destroy
                                end


                                t.destroy
                              end
                              
                              
                              ProjectMember.delete(self.project_members.map{|m| m.id})
                              

                              self.project_folders.each do |p|
                                p.files.each do |f|
                                  rval = p.remove(f.guid)
                                  if rval[0] == false then
                                    message = rval[1]
                                    raise "errors"
                                  end
                                end
                                filepath = "shared/project_documents/#{self.id}/#{p.folder}"
                                if FileTest.exists?("#{filepath}")
                                  FileUtils.remove_dir(filepath,false)
                                end
                                p.destroy
                              end

                              filepath = "shared/project_documents/#{self.id}"
                              if FileTest.exists?("#{filepath}")
                                FileUtils.remove_dir(filepath,false)
                              end
                              

                              Project.delete(self.id)

                              return [true,""]

                              end
                            end
                          end
                        end  
                      end  
                    end
                  end
                end
              end
              end
              end
            rescue Exception => exc
              if exc.to_s != "errors" then
                message = {"project_error"=>"Error in project deletion:"+exc.to_s}
              end
              puts message.inspect
              return [false,message]

            end
  end
  
end


