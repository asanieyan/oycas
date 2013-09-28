module OycasHelpers      
   module UrlRewrite
      #returns the url 
      def url_for_back fall_back_url=""
           if request.env['HTTP_REFERER']
              return request.env['HTTP_REFERER']
           else
              fall_back_url
           end
      end        
      #returns the url for a student
      def url_for_student student, options={}
             if @me and @I.am? student                
                controller = 'my'
                action = options.delete(:action) || 'home'
             else
                controller = 'student'
                action = options.delete(:action) || 'profile'
                options[:sid] = student.guid                
             end
             return options.update({:controller=>controller,:action=>action})
      end
      #return the klass url
      def url_for_klass klass, options={}
             klass ||= 0
             if klass.is_a? Klass
                guid = klass.guid
             else
               guid = klass
             end                           
             options[:action] = options[:action] || 'index'
#             if options[:action] == 'index'
#                return "/class/" + (klass.course.subject+klass.course.number).downcase + "d" + klass.division.to_s
#             end
             return klass_url({:cid=>guid}.merge(options)) 
      end
      def url_for_school school,params={}             
            options = {:schid=>school.guid,:code=>school.short_name.downcase}.merge(params)
            return school_url(options) 
      end
      def url_for_course course,params = {}
          options = {:courseid=>course.guid,:course=>(course.subject + "-" + course.number).upcase.gsub(/\s/,"")}.merge params
          return course_url(options)
      end
      def help_url_for method,options={}
          topic = options.delete(:topic) 
          ["/help/#{method}/#{topic}",{:pop=>true,:pop_options=>options.merge({:title=>image_tag('/images/help.gif'),:remove_canvas=>true})}]
      end
   end
   module UrlHelper
      include UrlRewrite
      #overwrite the link_to
      def link_to(name, options = {}, html_options = nil, *parameters_for_method_reference)
          if html_options and html_options[:pop] 
               html_options.delete(:pop)
               return link_to_popup(name,options,html_options)
          end
          if (html_options || {})[:_confirm]
                msg = html_options.delete(:_confirm)
                html_options[:confirm] = ["Confirmation",msg]
          end
          if (html_options || {})[:confirm].is_a? Array
                title,message,pop_options = html_options.delete(:confirm)
                joptions = ({:title=>title,:message=>message,:url=>url_for(options)}.merge(pop_options || {})).to_json
                html_options[:onclick] = "Confirm(#{joptions});return false;"
          end          
          return super(name,options,html_options,parameters_for_method_reference)
      end
      def link_to_block (options={},html_options=nil,*parameters_for_method_referencem,&block)
          content = (capture(&block))
          link = link_to "#{content}",options,html_options,parameters_for_method_referencem
          concat link,block.binding
      end   
      def link_to_back name,link={},options=nil
          
          link_to name,url_for_back(link),options
      end 
      def link_to_help name,method,options={}
          link,options = help_url_for(method,options)       
          link_to name,link,options
      end
      def button_to(name, options = {}, html_options = {})          
          html_options[:class] = html_options[:class] || "button-link"
          html_options[:method] = html_options[:method] || :get
          disable = html_options.delete :disable
          if disable == true
            html_options["disable_with"] = value unless html_options["disable_with"]
          end
          super name,options,html_options
      end
      def link_to_klass klass
          return nil unless klass.is_a? Klass
          link_to klass.name,url_for_klass(klass)
      end
      def link_to_student name,student=nil,options = {}                    
          if name.is_a? Student
            options = student || {}
            student = name
            name = student.name(:full)
          end  
#          if @I.am? student and (my_name=options.delete(:my_name))                                          
#             name = my_name
#             if option[:link_me] == false
#             return name
#          end
          if @me and @I.am? student and options[:link_me]
              val1,val2 = options.delete(:link_me)
              if val1.is_a? String
                        name = val1                                                                 
              end
              return name unless val2
          end
          link_to name,url_for_student(student)
#          if @I.can_see_profile_of? student or @admin
#            link_to name,url_for_student(student)
#          else
#            name
#          end
      end
  end
end

