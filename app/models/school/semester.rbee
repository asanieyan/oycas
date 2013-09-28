class Semester < ActiveRecord::Base
    belongs_to :season
    has_many :klasses
    has_many :course_notes
    belongs_to :school
    
    def before_create
      self.__current__ = :y
    end
    def name
        return self.season.name.capitalize + " " + self.start_date.year.to_s
    end
    def s_name
        return self.season.name.capitalize + " " + self.start_date.year.to_s #self.__year__.to_s.sub(/20/,'')
    end
    def num_days_left
#        #return the number days left until end of semester 
#        #if the semester is over then return 0         
#        x  = (end_date - Time.now).to_i / 60 / 60 / 24
#        x = nil if x < 0
#        return x
    end
#    def start_date
#        return Time.utc(__year__,season.start_month)
#    end
#    def end_date        
#        return Time.utc(__year__,season.end_month,Time.days_in_month(season.end_month,__year__))        
#    end
#    def year;__year__;end;
end
  
