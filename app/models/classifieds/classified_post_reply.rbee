class ClassifiedPostReply < ActiveRecord::Base
  belongs_to :post, :class_name=>'ClassifiedPost',:foreign_key=>'post_id'
  belongs_to :replier,:class_name=>'Student',:foreign_key=>'replyer_id'
  
  strip_tags_and_truncate 'subject','reply'
  def validate

  end
  
end
