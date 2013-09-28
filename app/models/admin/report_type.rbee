class ReportType < ActiveRecord::Base
  has_many :report_reasons, :foreign_key=>'report_type_id',:dependent=>:delete_all
  has_many :reported_items, :foreign_key=>'report_type_id',:dependent=>:delete_all
  def == object
      self.item_type.to_s == object.to_s
  end
  def to_s
      self.item_type.to_s
  end
end
