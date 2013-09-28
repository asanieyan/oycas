module StudentDisplay
    def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods
    end 
    module ClassMethods
        def add_student_display_methods owner,students_source,object_name = 'student'              
              @student_owner = owner
              @student_object_name = object_name
              @student_source = students_source
        end   
        def eval_students binding    
            [eval(@student_owner,binding),eval(@student_source,binding)]
        end 
    end
    module InstanceMethods
        def students_in_tab           
            @student_owner,students = self.class.eval_students binding
            @students = students.who_match(:order=>"last_access_time DESC")
            @student_display_paginator,@students = paginate @students,:per_page=>10
            @student_object_name =  self.class.instance_variable_get("@student_object_name") || "student"
            render_p 'student/students_small_view'
        end
        private
        def parse_filter_query                              
              params[:commit] = true
              options = {:conditions=>{}}
              options[:conditions][:gender] = (Student.values_of('gender')[params[:g].to_i]) if params[:g]
              options[:conditions][:relationship_status] = (Student.values_of('relationship_status')[params[:r].to_i]) if params[:r]
              conditions =  params[:q] ? [['whole_name LIKE ?'],'%'+params[:q]+'%'] : [[]]
              if params[:v] == "on"
                  conditions[0] << "login_time > logoff_time AND last_access_time > '#{2.hours.ago.to_formatted_s(:db)}'"
              elsif params[:v] == "off"
                  conditions[0] << "(last_access_time IS NULL OR last_access_time <= '#{2.hours.ago.to_formatted_s(:db)}')"
              end
              options[:conditions].each do |k,v|
                  if v                    
                      conditions[0] << "#{k} LIKE ?"
                      conditions << "#{v}"
                  else
                    options[:conditions].delete(v)
                  end
              end
              if conditions[0].empty?
                  conditions = nil 
              else
                  conditions[0] = conditions[0].join(" AND ") 
              end            
              options[:conditions] = conditions             
              options[:order] = case params[:s]
                                    when "a";"whole_name ASC, last_access_time DESC"
                                    when "mp";"avg_rate DESC, votes DESC, last_access_time DESC"
                                    else "RAND()"                                    
                                end
              return options                                                 
        end
        public
        def students_in_full            
            @student_owner,@students = self.class.eval_students binding            
            if params[:commit] or params[:q]
              @students = @students.who_match parse_filter_query
            else
              @students = @students.active
            end              
            @student_display_paginator,@students = paginate @students,:per_page=>10
            @student_object_name = self.class.instance_variable_get("@student_object_name")
            render :template=>'student/students_browse_view'
        end        
        def rate_students                        
            @student_owner,@students = self.class.eval_students binding
            sql_params = params[:commit] || params[:q] ? parse_filter_query : {}            
            if sql_params[:conditions]
              sql_params[:conditions][0] << " AND students.rate_option LIKE 'y' AND profile_image_set LIKE 'y' AND students.id <> #{@my.id}"
            else
              sql_params[:conditions] = "students.rate_option LIKE 'y' AND profile_image_set LIKE 'y' AND students.id <> #{@my.id}"
            end
            @paginator,@students = paginate @students.who_match(sql_params),:per_page=>10
            render :template=>'student/students_rate_view'
        end
    end   
end