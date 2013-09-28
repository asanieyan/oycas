class OycasBlog < ActiveRecord::Base
  belongs_to :oycas_user ,:class_name=>"Admin",:foreign_key=>"oycas_userid"
  has_many :comments, :as=>:commentable,:dependent=>:delete_all,:order=>"created_on ASC"  #,:foreign_key=>"blog_id",:dependent=>:delete_all,:order=>"created_on ASC"
  
  strip_tags 'subject'
  def year;created_on.year;end;    
  def month;created_on.strftime("%B");end;
  def before_create
    self.month_id = created_on.year.to_s + created_on.month.to_s 
  end

  def validate
    max_characters = 2
    errors.add('subject',"Please enter a subject") if self.subject.size == 0
    errors.add('subject',"Your post must be at least #{max_characters} characters") if ActiveRecordTextHelper::strip_tags(text).size < max_characters
  end
  
end
