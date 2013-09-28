class Season < ActiveRecord::Base
  has_many :semesters
  belongs_to :school
  def self.create_new_semester season,options={}
    begin
      semester = Semester.new
      semester.start_date = season.start_date
      semester.end_date = season.end_date
#      semester.class_start = season.default_class_start_date
#      semester.class_end = season.default_class_end_date
#      semester.exam_end = season.default_exam_end_date
      semester.school =  season.school
      semester.season = season
      return semester
    rescue Exception=>e 
#      p e.message      
    end
  end
  
  def start_date
    Time.utc(Time.now.year,start_month,1)
  end
  def get_date_compared_to_start month,day=nil   
    year = month.to_i < start_month ? Time.now.utc.year+1 : Time.now.utc.year
    date = if day 
              Time.utc(year,month,day) rescue Time.utc(year,month).at_end_of_month
           else
              Time.utc(year,month).at_end_of_month
           end
    return date
  end
  def end_date
       get_date_compared_to_start(end_month)     
  end
#  def default_class_start_date
#        get_date_compared_to_start(class_start.split("/").first,class_start.split("/").last)
#  end
#  def default_class_end_date
#        get_date_compared_to_start(class_end.split("/").first,class_end.split("/").last)
#  end
#  def default_exam_end_date
#        get_date_compared_to_start(exam_end.split("/").first,exam_end.split("/").last)
#  end
  
  def is_current_season?   
    month_range = if start_month <= end_month
                    (start_month..end_month).to_a
                  else
                    (start_month..12).to_a + (1..end_month).to_a
                  end

    month_range.include?(school.current_time.to_date.month)
  end
end
