class CategoryAssesment
  attr_accessor :title,:field_name,:prepend_text,:choices,:total_votes,:num_comments
  def initialize title,field_name,values,prepend_text=nil
       @title = title
       @field_name = field_name
       @values = values
       @prepend_text = (prepend_text || "said")  
       @total_votes = 0
       @choices = []          
  end
  def add_choice_result choice, num_votes 
        choice_text = @values[choice]
        if choice_text #if the choice is valid 
            @choices << [@prepend_text + " " + choice_text,num_votes]
            @total_votes += num_votes
        end
  end
  def sort
      @choices.sort! {|a,b| b[1]<=> a[1]}
      @values = nil;
      
  end
  def format assessed_value
        ((assessed_value[1].to_f / total_votes.to_f) * 100).to_i.to_s + "% #{assessed_value[0]}"
  
  end
end
class Assesment
  attr_accessor :categories, :instructor, :course
  def comments_for field_name,arg1,arg2=nil
         sql_condition = (sql_for arg1,arg2) + " and assessment_#{field_name}_comments LIKE '%'"
                 
         return (KlassEnrollment.find(:all,:select=>"klass_id,student_id, assessment_#{field_name}_comments as body",:conditions=>sql_condition)  rescue nil)       

  end
  def categories_for instructor,course
      _categories = []      
      if instructor 
            #InstructorPersonalityAssessments
            _categories = [ 
                   CategoryAssesment.new("Instructor's sense of humor","humor",["very funny","sometimes funny","so borning"],"said this instructor is"),
                   CategoryAssesment.new("Instructor's Knowledge of the material","knowledge",["doesn't know any","knows alot","knows a bit"])     
      
            ]
      end
      #AcademicAssessments
      _categories += [
                      CategoryAssesment.new("Assignment and Projects","assignments_projects",["very hard but challanging","very hard and very boring","so easy"],"said they were"),
                      CategoryAssesment.new("Quizes and Midterms","quizes_midterms",["very hard but challanging","very hard and very boring","so easy"],"said they were"),
            
                  ]   
      return _categories              
  end
  def sql_for arg1,arg2=nil
  
       sql_condition = []     
       if arg1.class == Instructor
          @instructor = arg1
          @course = arg2          
       else
          @course = arg1
          @instructor = arg2       
       end     
       if instructor            
            sql_condition << "instructor_id = #{@instructor.id}"
       end
       if course 
            sql_condition << "course_id = #{@course.id}"       
       end
       return  sql_condition.join(" and " )
  
  end
  def assesment_for arg1,arg2=nil
#       ApplicationController.logger.debug "getting assesment for #{arg1.class.to_s} #{'and' + arg2.class.to_s if arg2}"       
       sql_condition = sql_for arg1,arg2
       @categories = categories_for @instructor,@course
       @categories.each do |cat| 

           recs = KlassEnrollment.find(:all, :select=>" assessment_#{cat.field_name} as choice, count(*) as num_selected ",
                                 :group=>"assessment_#{cat.field_name}",
                                 :conditions=>sql_condition)
           cat.num_comments = KlassEnrollment.count(:select=>"assessment_#{cat.field_name}_comments",:conditions=>sql_condition)
#           ApplicationController.logger.debug cat.title
#           ApplicationController.logger.debug recs.inspect
#           ApplicationController.logger.debug cat.num_comments
           recs.each do |rec|
               next unless rec.choice
               cat.add_choice_result rec.choice.to_i, rec.num_selected.to_i

           end
#            cat.grouped_assessments.empty? ? categories.delete(cat) :
             cat.sort
#           ApplicationController.logger.debug cat.inspect 
       end
       return self
#       categories.delete_if {|e| e.grouped_assessments.empty?}
  end
end
