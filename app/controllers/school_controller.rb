
class SchoolController < ApplicationController

  before_filter :validate
  
  verify :method=>'post',:only=>%w(desc_for_course 
                          courses_of_subject),:redirect_to=>{:action=>'index'}
  verify :flash=>:member,:only=>%w(register_for_course desc_for_course 
                          courses_of_subject course_catalouge)

  
  include Scrapalious
  include StudentDisplay    
  include Forums
  
  def render_menus   
    add_menu 'School Home',:action=>'main'
    add_menu 'School Courses',:action=>'course_catalouge'
    forum = add_menu 'Discussions',:action=>'forum_topics'
      forum.add_sub_menu 'Start New Topic',:action=>'new_forum_topic'     
    #add_menu("My Courses",{:depends_on_sub=>true},nil,MyHelper::render_course_items)      
  end  
  
  add_forum_methods "@school"
  add_scrap_methods "@school"
  add_student_display_methods "@school","@school.students"

  alias students students_in_full
  def students_in_full; redirect_to :action=>'students';end;
  
    def deregister_from_all_courses        
        @school.student_drop_all_courses(@me)
        redirect_to :back
    end
    def deregister_from_course
        begin
          @course = Course.find(params[:course_id])
          @school.student_drop_course(@me,@course.id) 
          if request.xhr?
              render_p  'school/desc_for_course'
              return
          end          
        rescue

        end
        redirect_to :back        
    end
    def read_rss
        begin
          index =  params[:id].to_i / @school.guid
          raise if index == 0
          item = @school.news_feed.channel.items[index-1]
          raise unless item
          StringCounter.add_entry(item.link)
          redirect_to item.link
          return
        rescue Exception=>e
#            p e.message
            render :nothing=>true
            return         
        end
    end
    def switch_class     
      if request.xhr?
        begin 
          @klass = Klass.find(params[:klass_id])
          @course = @klass.course
          @school.student_drop_course(@me,@course.id)
          if @school.student_can_register?(@me)
            @klass.enroll_student @me
          end
        rescue Exception=>e
            render :nothing=>true
            return
        end     
        render_p  'school/desc_for_course'
      else
        redirect_to :back
      end
       
    end
  
    def register_for_course
        @course = Course.find(:first,:conditions=>["school_id = #{@school.id} AND id = ?",params[:id]])
        #course belongs to this school 
        #if i am here then i am part of this school
        if request.xml_http_request? 
          if @course.student_registered(@me)
            render :text=>true
            return
          end
          render_p 'course_register'
          return
        elsif not @course.student_registered(@me) and @school.student_can_register?(@me)          
              #if there is a class id 
              begin
                Klass.transaction do 
                     KlassSchedule.transaction do
                        if params[:klass_id]
                            @klass = Klass.find(:first,:conditions=>["semester_id = #{@school.current_semester.id} AND school_id = #{@school.id} AND course_id = #{@course.id} AND id = ?",params[:klass_id]])                                                                  
                            raise unless @klass
                        else
                            #create the klass first
                            @klass = Klass.create(:course_id=>@course.id,:school_id=>@school.id,
                                                  :semester_id=>@school.current_semester.id)    
                            @klass.set_time params[:day]
                        end  
                        @klass.enroll_student @me                                                 
                   end
                end  
              r_msg 'search-msg'=>"You successfully registered in <strong>#{@course.short_title}</strong>.",:type=>'success'
              rescue Exception=>e
                  redirect_to :action=>'main'
                  return
              end
            begin
              redirect_to :back                   
            rescue
              r_msg :welcome=>"Welcome to #{@klass.name}",:type=>"alert",:hide=>"true",:position=>'bottom'              
              redirect_to "/class/#{@klass.guid}/main"
            end
            return
       end        
       render :nothing=>true
    end

    def desc_for_course
        begin
          @course = Course.find(:first,:conditions=>["school_id = #{@school.id} AND id = ?",params[:id]])
          render_p  'school/desc_for_course'
          return;
        rescue
        
        end
        render :nothing=>true

    end
    private 
      def get_courses_of_subject subject_id
  #        unless read_fragment({:subject=>params[:s],:page => params[:page] || 1})
              begin               
                subject = CourseSubject.find(:first,:conditions=>["school_id = #{@school.id} AND id = ?",subject_id])
                paginator, courses = paginate subject.courses,:per_page=>10
              rescue Exception=>e
                return nil
              end
              return [paginator,courses,subject]
  #        else
  #          render_p  'school/courses_of_subject'
  #        end
  
      end  
      def get_search_for_course search_value,subject_id=nil
          course_number = []
          course_name_and_subject = []
          (values = search_value.split(" ")).each do |portion|            
              if portion =~ /\d+/
                  course_number << portion
              elsif portion.size >= 3
                  course_name_and_subject << portion                
             end
          end
          course_number = course_number.join('%')
          course_name_and_subject = course_name_and_subject.join('%')          
          if course_name_and_subject.size == 0 and subject_id == nil
            return [],[]
          end       
          subject_search = "course_subject_id = #{subject_id} AND" if subject_id
          paginate :courses,:per_page=>10 ,:conditions=>
                                ["#{subject_search} school_id = #{@school.id} AND (concat(name , subject) LIKE ? OR concat(subject ,  name) LIKE ? ) AND number LIKE ?",
                                  "%" + course_name_and_subject + "%","%" + course_name_and_subject + "%","%" + course_number + "%"]
                                                             
      end
    public     
    def course_catalouge
        if params[:q]
#            @subject = CourseSubject.find(params[:s]) rescue nil
          @paginator,@query_results = get_search_for_course params[:q],params[:s]
        elsif params[:s]
          @paginator,@courses,@subject = get_courses_of_subject params[:s]          
        end
        
    end    
  def index     
      redirect_to :action=>'main'
  end
  def main
    
  end
  def classifieds
      redirect_to classifieds_url(:controller=>'classifieds' ,:network=>@school.network.name)
  end

 private
    def validate
          @school = School.find_by_guid(params[:schid])          
          if @school               
           flash[:member] = @I.am_member_of?(@school)           
           return true
          else
            redirect_to :controller=>'my'
            return false
          end          
    end
   
end
