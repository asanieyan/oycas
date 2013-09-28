#contains all of the single item that has many reports 
class ReportedItem < ActiveRecord::Base
  belongs_to :reported_student,:class_name=>'Student',:foreign_key=>'student_id'
  belongs_to :report_type, :foreign_key=>'report_type_id'
  has_many :reports, :order=>'created_on DESC',:class_name=>'ItemReport',:foreign_key=>'report_id',:dependent=>:delete_all do
        def summary
            unless @stats 
                @stats = find(:all,:select=>"count(*) as num, reason ",
                              :joins=>'join report_reasons on reason_id = report_reasons.id ',
                              :group=>'reason_id',:order=>'num DESC'                        
                        )
                
                @stats = [@stats].flatten
                class << @stats    
                                 
                    def num_reports
                         @sum ||= self.inject(0){|s,i| s += i.num.to_i;}
                    end
                end
            end
            @stats
        end  
  end
  def flags
      reports
  end
  def is_resolved?;resolved;end  
  def has_been_resolved comments=""
      self.resolved = :y
      self.resolved_time = Time.now.utc
      self.resolved_comments = comments
      self.save
  end
  def reported_item     
      @reported_item ||= begin                                                               
                           case report_type.item_type
                              when :profile; Student.find(reported_item_id)
                              when :photo;AlbumPhoto.find(reported_item_id)
                              when :classified; ClassifiedPost.find(reported_item_id)
                              else;nil                              
                           end
                         rescue Exception=>e                          
                            nil
                         end
  end
  def violator;reported_student;end
  alias item reported_item
  def self.generate_report reporter_student_id,reported_student_id,item_type,reported_item_id,reason_id,comments      
      #find the item_type id       
      item_type = ReportType.find(:first,:conditions=>['item_type LIKE ?',item_type])
      reason = ReportReason.find(reason_id)      
      raise unless reason.report_type_id == item_type.id       
      report = ReportedItem.find(:first,:conditions=>["resolved IS NULL AND report_type_id = #{item_type.id} AND reported_item_id = ?",reported_item_id])
      ReportedItem.transaction do 
        ItemReport.transaction do
          report = ReportedItem.create(:student_id=>reported_student_id,:reported_item_id=>reported_item_id,:report_type_id=>item_type.id) unless report
          report.num_reports += 1
          report.last_report_time = Time.now.utc
          ItemReport.create(:report_id=>report.id,:reporter_id=>reporter_student_id,:reason_id=>reason.id,:comments=>comments)
          report.save
        end
      end
  end
end
#reports of the above class
class ItemReport < ActiveRecord::Base
  belongs_to :item, :class_name=>'ReportedItem',:foreign_key=>'report_id'
  belongs_to :reporter, :class_name=>'Student',:foreign_key=>'reporter_id'
  belongs_to :reason, :class_name=>'ReportReason',:foreign_key=>'reason_id'
end
