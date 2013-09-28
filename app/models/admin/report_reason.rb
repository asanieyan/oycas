class ReportReason < ActiveRecord::Base
  belongs_to :report_type, :foreign_key=>'report_type_id'
  def self.[] item
      find(:all,:select=>"report_reasons.* ",:joins=>'join report_types ON report_types.id = report_reasons.report_type_id',
          :conditions=>['report_types.item_type LIKE ?',item])
  end
  def to_s
      self.reason
  end
  def self.load_from_yml(yml)
      yml.each do |type,reasons|
          rt = ReportType.find(:first,:conditions=>"item_type LIKE '#{type}'")
          unless rt
              p 'creating report type: ' + type
              rt = ReportType.create(:item_type=>type) rescue nil
          end                                        
          next unless rt
          reasons.each do |reason|
            p "creating a reason for the type '#{type}' : " + reason
            ReportReason.create(:report_type_id=>rt.id,:reason=>reason) rescue nil
          end

      end  
  end
end
