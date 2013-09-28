class ClassifiedsController < ApplicationController
    
    include ClassifiedsHelper
    include News
    def render_menus
        add_menu 'Browse','/classifieds/network/#{params[:network] || @my.default_school.network.name}/browse'
        add_menu 'Post an Item','/classifieds/network/#{params[:network] || @my.default_school.network.name}/select_category_to_post'
        add_menu 'My Posts',"/classifieds/my_posts"
    end
    def calendar
        render_p 'shared/calendar'
    end
    def index
      redirect_to :action=>'browse'
    end
    def browse            
      @nodes = CategoryTreeNode.roots       
    end
    def update_sub_categories
          #a node is selected 
          #we must return its children nodes
          #or return nothing if it has no children
          node = CategoryTreeNode.find_by_classified_category_id(params[:category_id])          
          unless node 
            render :nothing=>true
            return
          end
          if node.children.size > 0 
              levels = [[node.children]]
              selected_leaf = nil
          else
              levels = []
              selected_leaf = node
          end
          render(:update) {|page| 
              page.replace_html(params[:update_div],:partial=>'classifieds/same_level_categories', :locals=>{'levels'=>levels,'selected_leaf'=>selected_leaf})              
          }              

    end
    def attach_images_to_post 
        flash.keep(:attached_images_to_post_in_flash)       
        flash[:attached_images_to_post_in_flash] = {} unless flash[:attached_images_to_post_in_flash]         
        @max_images = 10       
        @num_images = 0            
        if params[:post_id]                   
          post = ClassifiedPost.find(params[:post_id]) rescue nil
          unless post and post.poster_id == @my.id
           redirect_to :back
           return
          end
          @num_images = post.images.size 
        end
        @num_images += flash[:attached_images_to_post_in_flash].size          
        if request.post? and not request.xml_http_request?                 
           ids = []
          images = DocumentFile.truncate(params[:uploaded_images],
              {:filter_in=>DocumentFile::SuppoertedImages,:max_size=>4.megabytes})
           images.each do |file| 
              #transfer the image file to jpep and save them in flash
              #save the images in the flash 
              break if @num_images >= @max_images #this make sures that not more than max_images are inserted in the flash
              if  file.size > 0 #file with data
                  #resize the image                   
                  image_tmp_id =  (rand(1000) * Time.now.to_i).to_s + 'tmp'
                  #this make sures that image_id is always greater than 10
                  #so it won't get confused with image id of a already saved post
                  #whose id is just a number between 0 and 9 
                  begin
                    image = Image.resize_to((data=file.read),"500x500")                     
                    thumb = Image.resize_to((data),"100x100")                                          
                    raise unless image and thumb
                    flash[:attached_images_to_post_in_flash][image_tmp_id] = {:thumb=>thumb,:image=>image}    
                    @num_images += 1
                  rescue

                  end                                    
              end           
           end         
           params.delete(:uploaded_images)
           flash[:saved_params] = params             
           redirect_to((request.env['HTTP_REFERER'].gsub("#i",'') + "#i"))
           return 
        elsif params[:image_id]            
            if params[:remove]                
                #this doesn't whether the image belongs to the post yet 
                #or not it pretty fast so it just tries to delete both of them
                if post and params[:image_id] !~ /tmp/
                    #this post belongs to logged in  user 
                    post.delete_image params[:image_id]
                else
                    flash[:attached_images_to_post_in_flash].delete(params[:image_id])                         
                end                
                render :nothing=>true
            else
                begin
                  data = flash[:attached_images_to_post_in_flash][params[:image_id]][:thumb]
                  send_data data, :disposition=>'inline',:type=>'image/jpeg'
                rescue Exception=>e
                                    
                    render :nothing=>true
                end
            end           
            return
        end        
        #request is to get attachment form
        render_p "classifieds/attach_image"

    end
    alias get_attached_images_to_post attach_images_to_post
    verify :method=>:post,:only=>'commit_posting_item'
    def commit_posting_item                           
          flash.keep(:attached_images_to_post_in_flash)         
          category = ClassifiedCategory.find(params[:category_id]) if params[:category_id]
          post = nil
          if params[:post_id]
              post = ClassifiedPost.find(:first,:conditions=>["poster_id = #{@me.id} AND id = ?",params[:post_id]])
          end
#              logger.debug "is category a leaf : " + (category.node.children.size == 0).to_s              
          unless (category and category.node.children.size == 0) or (params[:post_id] and not post)
              redirect_to :action=>'browse'
              return 
          end          
          #form is submitted here 
          #title mandetory
          #a hash of attributes id related to this category              
          #will recieve school_id optional
          #bunch of course ids options optional
          #since a student is not able to associate a post to a course not of his school
          #then we must make sure that the course_ids actually belong to with school_id              
          #this part will be heavily modfied because of the different attributes of each post
         
          errors = []                  
          validated_attribues = []           
          begin                       
            ClassifiedPost.transaction do #if anything goes wrong the transaction is cancelled
             ItemAttributeValue.transaction do                          
                  unless post 
                    post = ClassifiedPost.new :title=>params[:title],
                                              :description=>params[:message] || "",
                                              :poster_id => @me.id,
                                              :network_id=> @network.id,
                                              :classified_category_id=>category.id 
                   
                  else
                    post.attributes= {:title=>params[:title],
                                              :description=>params[:message],
                                              :poster_id => @me.id,
                                              :network_id=> @network.id,
                                              :classified_category_id=>category.id }
                  end
                  errors <<  post.errors unless post.save  
                  
                  #keeps the attributes that have been validated                    
                  (params[:attributes] || []).each do |attrb_id,attrb_value|
                        attrb_value_pointer = [attrb_value]
                        if (attrb = category.has_attribute attrb_id) 
                              #if this category has this attribute    
                              #if not this then it is a hack                                                             
                              #validify all the attibutes first then add them once 
                              #if one attribute is invalid then to add any of them but still validify them                                 
                             attrb.validify(attrb_value_pointer,params)
                             #if no error in attibute and no error so far add the attribute to the validated attributes
                             if attrb.errors.empty? and errors.empty?
                                validated_attribues << [attrb,attrb_value_pointer[0]]
                             elsif not attrb.errors.empty? 
                                #if invalid attribute keep it in the central error object
                                #this will prevent ever going to the first condition
                                #because errors becomes not empty 
                                validated_attribues = [] #since there is at least on invalid attribute no reason to keep them in the validted attribute array 
                                errors << attrb.errors
                             end                                    
                        else #this is a hack  
                           # post.errors.add("invalid","attribute for the category #{category.name}")
                            raise Exception, "Invalid attribute_id passed for category #{category.name} : possible hack"                   
                        end
                  end
                  #if any errors on the field do a rollback
                  raise Exception, "Post Invalid Value Error Exception "  unless errors.empty?
              end #end item attribute value transaction
            end #end category transaction                           
              rescue Exception=>e                       
     
                   r_msg 'post-messags'=>errors                                   
                   flash[:saved_params] = params    
                   redirect_to :back
                   return                
                 end
              
             post.school_id = @my.default_school #(@my_schools_in_network.find{|s| s.default_school} || @my_schools_in_network.shift).id     
             post.add_values  validated_attribues  
             
#COMMENT 2 COMES HERR
        begin
          (flash[:attached_images_to_post_in_flash] || {}).each_value do |_|                 
              image = _[:image]
              post.save_image image
           end
         rescue Exception=>e
            
         end
        
         post.save
         redirect_to url_for_category(category,:action=>'postings') 
         return           
    end
    def report_post
        begin
          post = ClassifiedPost.find(params[:id])           
          raise if post.poster_id == @my.id
          if not request.xml_http_request?            
              ReportedItem.generate_report(@me.id,post.poster.id,'classified',post.id,params[:reason],params[:comments])         
              redirect_to :back
              return
          end
          render_p 'report_classified_post'
        rescue
          render :nothing=>true
        end      
    end    
    verify :method=>:post,:only=>%w(reply_to_post report_post)
    def reply_to_post
        begin
          @post = ClassifiedPost.find(params[:id])
          unless @post.poster_id == @my.id
            if request.xml_http_request?
              render_p 'classifieds/reply_to_post'
              return
            else #request being committed
                 #send an email and 
                 #intranet message 
                 begin 
                   unless @post.poster.can_send_message_to?(@me) 
                     email = StudentContactEmail.find(params[:email]).address
                     raise "Invalid Email" unless email.student_id == @my.id and email.confirmed
                   else
                     email = nil
                   end
                   ClassifiedPostReply.create(:post_id=>@post.id,:replyer_id=>@my.id,:subject=>params[:subject],:reply=>params[:reply_message])                   
                   create_news_for_classified_post_reply @post.poster,@post
                   Notifier::deliver_classified_reply(@me,@post,
                        email,params[:subject],params[:reply_message]) if @my.classifieds_notification
                   IntranetMessage::deliver_message(@me,@post.poster,params[:subject],params[:reply_message])     
                 rescue Exception=>e
#                    p e.message                 
                 end            
                 redirect_to :back
                 return
            end
          end
        rescue Exception=>e
            render :text=>e.message
            return
        end
        render :nothing=>true
    end
    def posting_item  
          flash.keep                 
          @node = CategoryTreeNode.find(params[:id]) rescue nil
          unless @node and @node.children.size == 0
                redirect_to :action=>'select_category_to_post'
                return
          
          end
          @category = @node.category  
          @post = ClassifiedPost.new 
          begin
            @post.title = flash[:saved_params].delete('title')
            @post.description = flash[:saved_params].delete('message')
          rescue Exception=>e
          
          end
          request.env['HTTP_REFERER'] = url_for :network=>@network.name,
                                :category=>url_encode(@category.name),:action=>"postings"
          
        
    end
    def select_category_to_post                  
          @levels,@selected_leaf = get_tree @category            
    end
    verify :method=>'post', :only=>'delete_post'
    def delete_post
        begin
          post = ClassifiedPost.find(params[:id])
          if post.poster_id == @my.id
              post.destroy()
          end
          redirect_to :back
        rescue Exception=>e          
          redirect_to :controller=>'my'
        end                
    end
    def edit_post
        flash.keep
        begin
          @post = ClassifiedPost.find(params[:id])
          @category = @post.category
          @network = @post.network
          raise unless @post.poster_id == @my.id
          
        rescue Exception=>e 

          redirect_to :controller=>'my'
        end  
        begin 
            @post.title = flash[:saved_params].delete('title')
            @post.description = flash[:saved_params].delete('message')        
        rescue
        
        end
        render :template=>'classifieds/posting_item'   
    end
    def view_replies        
        @post = ClassifiedPost.find(params[:id]) rescue nil
        unless @post and @post.poster_id == @my.id
            redirect_to :action=>'my_posts'
            return
        end 
        
    
    end
    def my_posts
        @my_categories = ClassifiedCategory.find(:all,:select=>"DISTINCT *" ,                     
                      :conditions=>"EXISTS (SELECT NULL FROM classified_posts WHERE poster_id = #{@my.id} AND classified_category_id = classified_categories.id)")
        cond = if params[:cat]
                  ["poster_id = #{@my.id} AND classified_category_id = ?",params[:cat]]
               else
                  "poster_id = #{@my.id}"
               end
        @paginator, @my_posts = paginate :classified_posts,
                  :order=>"created_on DESC",
                  :conditions=>cond,
                  :per_page=>10
    end
    def show_my_post         
         begin
           @post = ClassifiedPost.find(params[:id])         
           if @post.poster_id == @my.id
              render :template=>"classifieds/show"  
           elsif 
              redirect_to :action=>'show',:id=>params[:id]
           else
              raise
           end                    
         rescue Exception=>e

            redirect_to :back
         end
    end
    def show
          @post = ClassifiedPost.find(params[:id]) rescue nil
          unless @post
              redirect_to :action=>'browse'
              return
          end
    end
    def postings                 
          if params[:category_id]
            category = ClassifiedCategory.find(params[:category_id]) rescue nil
            unless category == @category
                unless category         
                  redirect_to classifieds_url(:action=>'index')
                else
                  redirect_to url_for_category(category,params)                 
                end
                return
            end
         end      
        @posts = @category.posts_for(@network,params[:commit] ? params : {} ) 
        @paginator, @posts = paginate @posts, :per_page=>10

    end
  
  private
      def get_tree category
            tree = []
            selected_leaf = nil
            if category
              #@children = @category.node.direct_children              
              category.node.self_and_ancestors.each do |parent_node|                
                  #at each depth select between the parent node and its
                  #sibling the parent node is selected 
                  if parent_node.level == 0 
                      #root level
                     node_array =  parent_node.roots
                  else                
                     node_array = parent_node.self_and_siblings
                  end
                   tree << [node_array,parent_node.id]
              end             
              if category.node.children.size > 0 
                  #if this category has children then add them to the tree as well
                  tree << [category.node.children] 
              else 
                 selected_leaf = category.node
              end            
            else #if category is nil then just retur a tree consiting of the root
              tree << [CategoryTreeNode.roots]
            end        
            return tree,selected_leaf
      end
      before_filter :check_admin_action,:except=>'show'
      
      def check_admin_action
           return false if @I.am_admin? and action_name != "show"
      end
      before_filter :instanciate_network_and_category, 
            :except=>%w(calendar view_replies show_my_post delete_post edit_post my_posts attach_images_to_post get_attached_images_to_post
                update_sub_categories)
      def instanciate_network_and_category
        if @admin == nil then
#       logger.debug "validation the classified url"
        #the classifieds are routed from a school so
        #the links must contain the network they are coming from 
        #find all the networks i belong to 
        @my_networks = @my.networks.flatten
      
        #find the current network from my networks using that params[:network
        @network = @my_networks.find{|network| network.name.downcase == params[:network].downcase}        
        @my_networks = [] if @my_networks.size == 1
        unless @network
          
          redirect_to :controller=>'my'
          return
        end
        
        #by here I for sure belong to this network 
        #so there at least one school that i belong to in this network
        @my_schools_in_network = @my_schools = School.find_by_sql( 
         %(select schools.*,school_members.default_school from school_members,schools where school_members.student_id = #{@me.id} 
          and school_members.school_id = schools.id and schools.network_id = #{@network.id})
          )  
        else
          
          @network = Network.find(:first, :conditions=>["name=?",params[:network]])
            unless @network
              redirect_to :controller=>'my'
              return
            end
          @my_networks = []
          @my_schools = School.find_by_sql( 
         %(select schools.* from school_members,schools where school_members.school_id = schools.id and schools.network_id = #{@network.id})
          ) 
        end
          
        #if there is category parameter try to find it 
        #if it's an invalid category go back to browse
        if params[:category]          
            @category = ClassifiedCategory.find_by_name(URI.unescape(params[:category]))
            redirect_to "/classifieds/#{@network.name}"  unless @category      
        end
        
        
      end
    
end
#    def select_cands         
#       flash.keep
#       if params[:school_ids]          
#          @my_schools = School.find(params[:school_ids].split(","))
#          unless @my_schools.size > 0 
#            render :nothing=>true
#            return
#          end
#          @school = @my_schools.select{|s| s.id.to_s == params[:school_id].to_s}[0]
#          logger.debug @my_schools.inspect    
#          @school = @my_schools[0]  unless @school                 
#          logger.debug @school.inspect             
#          flash[:courses] = {}
#          flash[:school_id] = @school.id.to_s
#          #flash[:select] = params[:select]   
#       elsif params[:subject_id]         
#          if params[:remove]
#            flash[:courses].delete("s" + params[:subject_id])
##            logger.debug flash.inspect
#            render :nothing=>true
#            return 
#          end          
#          subject = CourseSubject.find(params[:subject_id])                
#          unless subject and @me.allowed_in_school subject.school and 
#              flash[:courses]["s"+subject.id.to_s] == nil  
#              render :nothing=>true
#              return
#          end
#          flash[:courses]["s"+subject.id.to_s] = true          
#       elsif params[:commit] #form of courseids are submitted        
#          ids = []
#          if params[:select] == "course"
#                match_ptr =  /\d+course_id/
#                hidden_field_name = "ids"
#                klass_name = "Course"
#          else
#                match_ptr =  /subject_ids/
#                hidden_field_name = "ids"
#                klass_name = "CourseSubject"                        
#          end
#          params.each do |key,value| 
#            if key =~ match_ptr
#              ids << value
#            end            
#          end                    
#          ids = ids.flatten[0,@max_course_select]          
#          objects = []
#          self.class.module_eval(klass_name).with_scope(:find=> {:conditions=> "school_id = " + flash[:school_id]}) do
#            objects = Module.class_eval(klass_name).find(ids) rescue []
#          end
#          str  = []
#          ids = []
#          objects.each do |obj|
#              str << (obj.title(:small) rescue "<strong>#{obj.code}</strong>(#{obj.name})")
#              ids << obj.id
#          end
#          
#          str = str.join(", ") || ""
#          ids = ids.join(",") || ""
#
#          if str.size == 0
#              link_name = "click here to add a #{params[:select]}"
#          else
#              link_name = "edit"
#          end          
#          courses = render_to_string :inline=><<EOF
#                        #{str}
#                         <%=hidden_field_tag '#{hidden_field_name}',"#{ids}" %>   
#                         <%=hidden_field_tag "school_id",#{flash[:school_id].to_s} %>                    
#EOF
#          render :update do |page|             
#              page.<< "Pop.close()"
#              page.replace_html('courses',"#{courses}")    
#              page.replace_html('course-edit-link',"#{link_name}")      
#          end
#          return          
#            
#       else 
#          render :nothing=>true
#          return
#       end       
#       
#       if params[:subject_id]
#            @select_options = subject.courses.map{|course| [course.title(:small),course.id]}
#            @subject = subject
#            @random_num = Time.now.to_i * rand(1000000)
#            @dom_id = "#{@random_num}course_id[]" #needs that so it can send multiple values 
#            @response =  "<div  id='#{@random_num}' style='display:inline'> " + 
#                         "<%=link_to_remote 'x', :loading=>\"$('subject_id').disabled = true\",:success=>\"$('subject_id').disabled = false\",:update=>@random_num,:url=>{:action=>'select_cands',:subject_id=>@subject.id,:remove=>true} %> " +
#                          " <%=select_tag @dom_id,options_for_select(@select_options) ,:size=>6,:multiple=>true ,:style=>'width:120px' %> " +
#                          "<script> $('#{@dom_id}').options[0].selected = true </script>" 
#                        "</div>" 
#           render :inline=>@response
#        else        
#          render :partial=>'classifieds/popup'
#        end        
#
#        
#    end  
#    
#    
#COMMENT 2
 #            *******************************************************************************                                      
#             Right now there is no supported for a post to be associated with a subject
#             or class
#              school_id = (params[:school_id]).to_i
#
#              post.school_id = school_id == 0 ? nil : (SchoolMember.find_by_school_id_and_student_id(school_id,@me.id).school_id rescue nil)
#              unless post.school_id
#                  post.associable_to = nil
#                  post.associated_names = nil
#                  post.associated_ids = nil
#
#              end
#              if category.associable_to and post.school_id and (ids = (params[:ids] || "").split(",")).size > 0
#              # verified that student is member of the school
#              # and this post has course associatio
#              post.school_id = school_id                  
#              if category.associable_to == :subject 
#                  klass_name = "CourseSubject"
#              else
#                  klass_name = "Course"
#              end
#              post.associable_to = category.associable_to                                      
#              klass = self.class.module_eval(klass_name)
#              ids = ids[0,@max_course_select]
#              objects = []
#              klass.with_scope(:find=>{:conditions=>["school_id = ?" ,params[:school_id]]}) do
#                      objects = klass.find(ids) rescue []
#              
#              end
#              post.associated_names = []
#              post.associated_ids = []
#              objects.each do |obj|
#                  logger.debug "creating association"                         
#                   post.associated_names << (obj.title(:small) rescue obj.code + ";;;" + obj.name)
#                   post.associated_ids << obj.id
#                  #ClassifiedCourseAssociation.create :classified_post_id=>post.id,:course_id=>course.id
#              end 
#              post.associated_ids =  post.associated_ids.join(",")
#              post.associated_names =  post.associated_names.join(",")                                     
#          end             
          #now save any pictures for this posting               
          #TO DO: This part must be synchronized between mongrel
          #processes to avoid multi submission 
#              id = rand(10000)              
#              logger.debug "process id : #{id}"
#              logger.debug "***************************************************************************"              
#             *******************************************************************************                                      

