module Note
    def self.included(base)
        base.extend(ClassMethods)
        base.send :include,CommonNoteMethods
        
    end 
    module ClassMethods
        def add_note_methods_for note_selector              
              if self.to_s ==  "MyController" or self.to_s == "StudentController"
                self.send :include, StudentInstanceMethods
              elsif self == CourseController 
                self.send :include, CourseInstanceMethods 
              elsif self == KlassController 
                 self.send :include, KlassInstanceMethods              
              else               
                return
              end
              @class_note_selector = note_selector              
        end
    end
    module CommonNoteMethods
      def print_courses
            name_or_subject,number = Course.parse_search_query_for_sql(params[:course_name])
            
            unless  name_or_subject.size > 2 #and number.size > 0
                render :nothing=>true
                return
            end 
#            name_or_subject = "%#{name_or_subject}%"
#            number = "#{number}%"
#            
#                  AND
#                  EXISTS( 
#                      SELECT NULL 
#                      FROM course_subjects as s 
#                      WHERE s.id = courses.course_subject_id AND 
#                            (CONCAT(s.code,s.name) LIKE '#{name_or_subject}' OR CONCAT(s.name,s.code) LIKE '#{name_or_subject}')
#                  )            
            
            number_condition =   number.size > 0 ? "number LIKE '#{number}%' AND" : ""
            results = Course.find(:all,
              :conditions=><<-eof 
                  #{number_condition} school_id IN (#{@my.schools.map{|s| s.id}.join(",")}) 
                  AND (subject LIKE '%#{name_or_subject}%' OR name LIKE '%#{name_or_subject}%') 
                  eof
                  ).map{|c| 
                                          
                      c.subject.gsub(/(#{name_or_subject})/i,'<strong>\1</strong>') + " " + 
                      (number.size > 0 ? c.number.gsub(/(#{number})/i,'<strong>\1</strong>') :  c.number) + 
                      " - " + 
                      c.name.gsub(/(#{name_or_subject})/i,'<strong>\1</strong>') + 
                      "<input type='hidden' value='#{c.id}'/>"
                  }            
            render_p 'shared/render_auto_completer',{'results'=>results}
        end
      def create_new
          render_p 'notes/create_note_from_binder'
      end
      def note_filters         
          set_context         
          if @note_context.is_a? Student
            condition = if @I.am? @note_context
                              "EXISTS ( SELECT NULL FROM course_notes WHERE owner_id = #{@note_context.id} AND course_id = courses.id )"
                          else
                              #if viewing someone else's notes
                              #only show the courses of notes that are not anonymous
                              "EXISTS ( SELECT NULL FROM course_notes WHERE anonymous IS NULL AND owner_id = #{@note_context.id} AND course_id = courses.id )"
                          end
            @notes_courses = Course.find(:all,:select=>"DISTINCT courses.*",:conditions=>condition) 
          end
          render_p 'notes/filter_tools'  
                    
      end      
      private 
        def set_context 
            @note_context = eval(self.class.instance_variable_get("@class_note_selector"),binding)          
        end
        def grab_notes
            params[:sort] ||= "ln"
            order = params[:sort] == "ln" ? "created_on DESC" : "num_downloads DESC,created_on DESC"
            conditions = {}
            conditions.update(yield)           
            if (params[:s] || "").size > 3
              conditions.update({:title=>('%' + params[:s] + '%')})
            else
              params[:s] = nil
            end
            conditions.update(:note_type=>params[:type]) if params[:type]
            
            sql = []
            #Hash condition is not supported in 1.6 must be it 
            #here myself
            conditions.each do |k,v|
                if v.is_a? Fixnum
                  sql << " #{k} = #{v}"
                elsif v.is_a? String
                  sql << " #{k} LIKE '#{v}'"
                elsif v == nil
                  sql << " #{k} IS NULL"
                end                
            end
            conditions = sql.join(" AND ")
            conditions = CourseNote.send :sanitize_sql,conditions
            @paginator,@notes = paginate :course_notes,:per_page=>(params[:view] == "lv" ? 20 : 10),:order=>order,
                                         :conditions=>conditions
                                          
                      
        end
      public
    end    
    module StudentInstanceMethods

        def show_notes
            set_context
            grab_notes do
                condition = {:owner_id => @note_context.id}
                unless @I.am? @note_context
                    condition.update(:anonymous=>nil)
                end
                if params[:c]
                  condition.update({:course_id=>params[:c]})
                end
                condition
                
            end
            #render :template=>'notes/student_show_notes.rhtml'
            render :template=>'notes/show_notes'  
        end
    end
    module CourseInstanceMethods
      def show_notes              
          @note_context = eval(self.class.instance_variable_get("@class_note_selector"),binding)     
          grab_notes do 
              {:course_id => @note_context.id}     
          end
          render :template=>'notes/show_notes'
      end         
    end
    module KlassInstanceMethods      
      def show_notes  
            
          @note_context = eval(self.class.instance_variable_get("@class_note_selector"),binding)     
          grab_notes do 
                 if params[:sel] != 'an'
                     {:klass_id=>@note_context.id}
                 else
                     {:course_id => @note_context.course_id}
                 end          
          end
          render :template=>'notes/show_notes'  
         
      end     
    end
end