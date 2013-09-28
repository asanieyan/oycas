class CourseController < ApplicationController

     before_filter :validate
     skip_before_filter :validate,:only=>%w(download delete_note edit_note)
     
     include Note
     add_note_methods_for "@course"
      def render_menus        
          add_menu("My Courses",{:depends_on_sub=>true},nil,MyHelper::render_course_items)      
      end
     
     def edit_note
        begin
          @note = CourseNote.find(params[:id])
          if @note.owner_id == @my.id
              if request.xhr?
                  render_p 'notes/edit_note'
                  return
              end             
              if request.post?
                  @note.title = params[:title]
                  @note.comment = params[:comment]
                  @note.anonymous = params["anon"] != nil ? :y : nil
                  @note.note_type = params[:note_type]
                  @note.save
                  redirect_to :back;
                  return
              end              
          end
        rescue Exception=>e
#            p e.message
        end
        render :nothing=>true;

     end
     def delete_note
        begin
          note = CourseNote.find(params[:id])
          if note.owner_id == @my.id
              note.destroy
          end
        rescue Exception=>e
        
        end
        redirect_to :back
     end
     def download
        begin          
          note = CourseNote.find_by_guid(params[:note])          
          note_file = note.read_file
          send_file note_file.path,:filename=>"#{note.title}.zip",:type=>"application/zip"
          unless note.belongs_to? @me
            note.num_downloads += 1
            note.save
          end
        rescue  Exception=>e
#          p e.message          
          render :nothing=>true
        end
     end
     def create_note
       @klass = @course.has_student?(@me)
       flash[:return_to_klass] = true if params[:ret] 
       if not request.xml_http_request?
          begin
            CourseNote.transaction do 
              c = CourseNote.create(  :course_id=>@course.id,:note_type=>params[:note_type],:klass_id=>(@klass ? @klass.id : nil),:owner_id=>@my.id,
                                  :school_id=>@course.school_id,:anonymous=>(params['anon'] ? :y : nil),
                                  :title=>params[:title],:comment=>params[:comment])
                                  
              raise unless c.id 
              c.files = params[:files]
              MiddleMan.new_worker(:class => :notify_mailer_worker,
                       :args =>[:new_note,c.id ]).delete     rescue nil
            end                        
              r_msg :message=>"Note created successfully." ,:type=>'success'  
          rescue DocumentFile::NoFile=>e    
              r_msg :message=>"Uploaded files are not of the supported type. if you have uploaded a zip file make sure that even the files within them are supported."  
          rescue DocumentFile::FileTooLarge=>e    
             r_msg :message=>"Upload size exceeds the maximum allowed size of #{CourseNote::MaxAllowedSize} Mb. Please try a smaller file."  
          rescue Exception=>e  
             logger.warn e.message
#            p e.message
          end 
          if flash[:return_to_klass] and @klass
            redirect_to klass_url(:cid=>@klass.guid,:action=>"show_notes")
          else
            redirect_to :back
          end
          return
       end
       
       render_p 'notes/create_new_note'
     end
#     def compare_comments
#        if request.xml_http_request? and params[:field_name]
#             comment_batches = []
#             largest_comment_set = nil
#             largest_comment_set_index = 0
#             flash[:assessment_attrbs].each do |course_id,instructor_id| #contains the compare assessment page assessments course,teacher
#                        course = Course.find(course_id)
#                        instructor = Instructor.find(instructor_id) if instructor_id
#                        #get a comments for field_name category for each of the course instructor comobs
#                        comment_batches << (comment_set = Assesment.new.comments_for params[:field_name],course,instructor)
#                        if comment_set.size > (largest_comment_set.size rescue 0) #find the largest set of comments 
#                             largest_comment_set = comment_set
#                             largest_comment_set_index = comment_batches.index comment_set
#                             logger.debug "found largest set at index = " + largest_comment_set_index.to_s
#                        end
#             end
#             if largest_comment_set #at least one set of comments that has at least one comment in it
#                  flash.keep(:assessment_attrbs) #for pagination
#                  flash.keep(:instructor_ids) #for pagination
#                  #need to paginate the comment_sets but to keep the paginator object 
#                  #of the largest set 
#                  paginator = nil
#                  instructor_params = {}                  
#                  paginated_batch =[]
#                  comment_batches.each_index do |index|                                                   
#                        logger.debug "paginating set #{index}"
#                        if largest_comment_set_index == index
#                            set,paginator = ApplicationHelper::get_paginator_for comment_batches.at(index),params[:page],2
#                            largest_comment_set = set
##                            logger.debug largest_comment_set_index
##                            logger.debug index
##                            logger.debug(largest_comment_set_index === index)
#                        else
#                             set,dummy = ApplicationHelper::get_paginator_for comment_batches.at(index),params[:page],2
#                             #work around for paginator 
#                             #since if paginator recieves a page number greater than its total number of pages
#                             #it will go back to the first page
#                             #in this case when we have a large_set and a small_set the small_set will loop when it reaches its last page
#                             #while the large_set will keep going
#                             #the expected behaviour is for the small_set to be nothing 
#                             if dummy.current_page.number < (params[:page] || 1).to_i
#                                  set = []
#                             end
##                             logger.debug dummy.current_page.number
#                             
##                             logger.debug "smaller set at page = #{params[:page] || 1} ; num comments = #{set.size}"
#                        end
#                        paginated_batch << set
#                  end
#                  
#                 flash[:instructor_ids].each do |key,value|    #serialize the instructor_ids to be passed as url
#                    instructor_params["instructor_ids[#{key}]"] = value
#                 end rescue nil   
#                 render :partial=>'course/compare_comments',:locals=>{'largest_set'=>largest_comment_set ,'comment_sets'=>paginated_batch,'paginator'=>paginator,'instructor_params'=>instructor_params}            
#                 return
#            end
#        end
#        render :text=> "A"                             
#     
#     end
#     def show_comments 
#        if request.xml_http_request? and params[:field_name]
#             teacher = Instructor.find_by_guid params[:instructor_id] if params[:instructor_id]
#             comments = Assesment.new.comments_for params[:field_name],@course,teacher
#             #if no comments found an array of size 0 is returend             
#             flash.keep(:instructor_ids)
#             if comments.size > 0                  
#                 comments,paginator = ApplicationHelper::get_paginator_for comments,params[:page],10
#                 instructor_params = {}
#                 flash[:instructor_ids].each do |key,value|                    
#                    instructor_params["instructor_ids[#{key}]"] = value
#                 end rescue nil
#               render :partial=>'course/show_comments',:locals=>{'comments'=>comments,'instructor_params'=>instructor_params,'paginator'=>paginator}
#               return
#             end
#        
#        end
#        render :text=>"no comments should never come here"
#     
#     end
#     def overview
#        load 'assesment_category.rb'        
#        
#        if request.xml_http_request? and params[:instructor_ids]
#                flash[:instructor_ids] = params[:instructor_ids] #store the instructor_ids
##               if params[:instructor_ids].size > 1 #multiple teachers
#                    #need to render another template
#                    assessments = []
#                    params[:instructor_ids].each do |teacher_guid,nothing| 
#                        
#                        teacher = Instructor.find_by_guid teacher_guid
#                        assessments << Assesment.new.assesment_for(@course,teacher) if teacher                        
#                    end
#                    if assessments.size > 1                                        
#                        flash[:assessment_attrbs] = assessments.map {|ass| [ass.course.id,ass.instructor.id]}
#                        render :partial=>'course/compare_assessments',:locals=>{'assessments'=>assessments}
#                        return
#                    else 
#                        assessment = assessments[0]
#
#                    end
##               end
#               
#        else
#                gui.panel1.head = render_html 'course/course_assessment_head', {}
#        end
#
#        assessment = Assesment.new.assesment_for @course unless assessment #Instructor.find(1) 
#        if request.xml_http_request? #only render the body
#              render :partial=>'shared/show_assessment',:locals=>{'assessment'=>assessment}
#        else
#            gui.append ['assessments',{'view comments'=>:dynamic}]
#            gui.assessments_tab.will do |tab|         
#                ['shared/show_assessment',{'assessment'=>assessment}]
#            end
#            render_view             
#        end 
#     end
#     def course_notes
#       notes = []     
#       semesters = []
#       (@course.course_notes).each {|note| if @me.allowed_to_see(note) then notes << note;semesters << note.semester end} 
#        semesters = semesters.uniq.sort {|sem1,sem2| sem2.__year__ <=> sem1.__year__}
#         
#      if request.xml_http_request?           
#         semester = Semester.find_by_id(params[:semid]) 
#         if semester
#              notes = [] 
#              (@course.course_notes).each {|note| notes << note if @me.allowed_to_see note and note.semester_id == semester.id }
#         end
#         view = :partial 
#      end        
#       #grab this course notes that @me can see and for every notes grab the semester of the note
#       unless notes and notes.size > 0 #there is no note for this course
#          gui.panel1.head = render_html "course/show_notes_head", 'semesters'=>nil
#          gui.panel1.content = 'course/show_notes',{'notes'=>nil}
#          render_view
#          return           
#       end
#       gui.append ['list'] #add the note tab
#      
#       gui.panel1.head = render_html "course/show_notes_head", {'semesters'=>semesters ,'selected_semester'=>(semester.id rescue "")}
#       gui.list_tab.will do |tab|
#             notes,paginator = ApplicationHelper::get_paginator_for(notes,tab.params[:page])                  
#            ['course/show_notes',{'paginator'=>paginator,'notes'=>notes} ]            
#       end       
#       get_note_info notes[0]          
#       render_view view
#     end
#     def share_notes
#            
#       @klasses = KlassEnrollment.find(:all, :conditions=>"course_id = #{@course.id} and student_id = #{@me.id}")
#       @klasses = nil if @klasses.length == 0
#       gui.panel1.content = render_html 'course/share_new_note', {}
#       render_view
#     end
   private 
      def validate                      
         begin
           @course = Course.find(params[:courseid])
           @school = @course.school
           raise "Not Registered in School" unless @school.has_student? @me
         rescue Exception=>e          
            p e.message
            return false;
         end
         return true
#         unless @course
#            redirect_to :controller=>"my"
#            return false
#         end
#         
#         if @admin != nil then
#          return true
#         end
#         
#         unless @me.allowed_in_school(@school = @course.school   )
#            redirect_to url_for_school(@school)
#         end
      end
end
