# Methods added to this helper will be available to all templates in the application.
class Tab 
    attr_accessor :name,:url,:options
    def initialize name,url,options={}
        @name = name
        @url = url
        @options = options
        @options[:xhr] = true if @options[:xhr] == nil
    end

end  
module ApplicationHelper
      #create standard oycas tabs
      #for a tab to work it needs
      #tab name: the name that reads a tab
      #tab url: the url of a content that tab points to 
      #partial_params: this determines whether the tab content is retrived using ajax or just as complete get request
      #if a array of [partial_file,{variables}] is given that means the url 
      class TabSet
         attr_accessor :tabs
         class NewTab
           attr_accessor :name,:url,:partial
           def initialize name,url,xhr
             @name = name
             @url = url
             if xhr.is_a? String or xhr.is_a? Array
               xhr = [xhr].flatten               
               @partial = xhr
               @xhr = false
             else
              @xhr = xhr
             end             
           end
           def partial
              @partial[0] rescue nil
           end
           def partial_locals 
             (@partial[1] || {}) rescue nil
           end             
           def has_a_partial?
             @partial
           end
           def uses_ajax?
             @xhr
           end

         end         
         def initialize
           @tabs = []
         end
         def add tab_name,tab_url,xhr=true
           @tabs.push(NewTab.new(tab_name,tab_url,xhr))
         end
         def each &block
           @tabs.each do |tab|
             yield(tab)
           end
         end
      end
      def create_tabs header_class,header_background,container_class,block
        html = ""
        block.call(tab_set = TabSet.new)
        selected_tab_for_content = tab_set.tabs.first.has_a_partial? ? tab_set.tabs.first : nil
        tab_set.each do |tab|
            tab_url = url_for(tab.url).gsub(/&amp;/,'&')                        
#            p tab_url + "==" + request.request_uri + ":" + (tab_url == request.request_uri).to_s
            selected = tab_url == request.request_uri
            selected_tab_for_content = tab if (selected and tab.has_a_partial?)              
            html << content_tag(:li,"",:name=>tab.name,:xhr=>tab.uses_ajax?,:selected=>selected,:url=>tab_url) 
          end    
        id = randID
        html = content_tag(:ul,html,:id=>id)          
        content = 
                  if selected_tab_for_content 
                    render_p selected_tab_for_content.partial,selected_tab_for_content.partial_locals
                  else 
                    ""
                  end        
        content_tag(:div,html,:class=>header_class,:style=>"background-color:#{header_background}") +               
        content_tag(:div,content,:class=>container_class) +
        javascript_tag("new Tabs('#{id}')")
      end
      def create_tabbed_flex &block
        create_tabs("flex_tab_div","white","flex_tab_content_container",block)
      end
      def create_tabbed_page title=nil,image=nil,&block                     
        (title ? create_page_title(title,image) : "") + create_tabs("header","#EEEEEE","tab_content_container",block) +
         content_tag(:style,"#content-panel {background-color:white;}") 
      end
      def create_page_title title="",image=[],&block
        html = ""
        image ||= []
        if block_given?                           
          title = []
          image = []
          block.call(title,image)
          title = title.first
        end
        unless image.empty?
          image = [image].flatten
          image_src = image.shift;
          image_options = image.shift || {}
          image_options[:style] = (image_options[:style] || "") + ";float:left;margin-right:10px;"
          html << content_tag(:div,image_tag(image_src,image_options))
        end    
        
        html << content_tag(:span,title)
        content_tag(:div,html,:class=>"title-box title-div",:style=>"margin-bottom:0px;padding-bottom:2px") + 
        content_tag(:div,"",:style=>'margin:0px;clear:left;height:0px;')
        
      end
    
    def create_flex_box title,flex=false,flex_options={},&block
        flex_id = escape_javascript(title.delete("'",'"',' '))
        if flex_options[:if] != nil          
          return unless flex_options.delete(:if)
        end
        title = content_tag(:div,title,:class=>'flex',:id=>flex_id)
        if block_given?                                  
          content = ""
          inside_css_options = {}
          dashboard_links = []
          label = []
          flex_content = (capture(inside_css_options,dashboard_links,label,&block))
          if flex_options[:border] == true
            flex_content = content_tag(:div,flex_content,:class=>"status-box")
          end
          inside_css_options[:style] ||= ""
          br = ""
          if !dashboard_links.empty?
             inside_css_options[:style] =';padding-top:2px' + inside_css_options[:style]
             content << create_flex_dashboard(dashboard_links) 
             br = "<br>"
          end
          if !label.empty?
             inside_css_options[:style] =';padding-top:2px' + inside_css_options[:style]
             content << create_flex_label(label.join(""))
             br = "<br>"
          end
          content <<  "<div style='clear:right;'>#{br}</div>" + flex_content
          content = title + content_tag(:div,content,inside_css_options.update(:class=>"flex-in",:id=>"#{flex_id}_in"))

          content << javascript_tag("new Flexer('#{flex_id}',#{flex_options.to_json})") if flex
          return concat(content,block.binding)
        end
        return title
    end
      def randID
          "ID" + rand(100000).to_s + "ID"
      end
      def generate_chat_topic key
        require 'digest/md5'
        token = ("oycas" + key.to_s + Time.now.to_date.to_s)       
        Digest::MD5.hexdigest(token)
      end
      def indicator
          "<span style='color:red'>*</span>"
      end
      def no_ajax_tabs *tabs,&block
         tabs.flatten!
         return if tabs.empty?
         render_p 'shared/no_ajax_tab',{'tabs'=>tabs,'block'=>block}         
      end
      def tabit(*tabs,&block)           
          tabs.flatten!      
          return no_ajax_tabs(tabs) unless tabs.first.is_a? String       
          div_id = tabs.shift
          update_page_tag do |page|
             tabset = "#{div_id}"             
             page << "var #{tabset} = new TabSet('#{div_id}')"          
             page << "tabarray = new Array"
             page << "currentTab = null"
             current_tab_set = false
             tabs.each do |tab|
                  tab_name = tab.name
                  tab_url = tab.url                                                                     
                  page << "var tab = new Tab('#{tab_name}','#{url_for(tab_url)}',#{tab.options[:xhr]})"
                  page << "tabarray.push(tab)"                  
                  if (session['tab_manager'][tabset] rescue "") == tab_name
#                    if not initial_content_method
#                      initial_content_method = "controller.#{tab_url[:action]}" #will raise an exception if the tab_url is not a hash 
#                    end
                    current_tab_set = true
                    page << "currentTab = tab"
#                    page << "currentTab.initialContent = '#{escape_javascript self.instance_eval(initial_content_method)}'"                   
                  end
             end
             unless (current_tab_set)
                  page << "currentTab = tabarray[0]"
#                  method = tabs[0][2] || "controller." + tabs[0][1][:action]                  
#                  page << "tabarray[0].initialContent = '#{escape_javascript self.instance_eval(method)}'"
             end
             page << "#{tabset}.setTabs(tabarray,currentTab)"
          end
      end
      def vertical_menus  *menus
          tag  = menus.last.is_a?(Hash) ? menus.pop : "div"                    
          menus_html = ""
          menus.each do |name,link,options|            
            menus_html << "<#{tag} class='menu-like-links'>" + link_to(name,link,options) + "</#{tag}>" 
          end
          return menus_html
      
      end
      def v_menus *menus
          menus.map{|m| "<div class='menu-like-links'>#{m}</div>"}.join("\n")
      end      
 
      def show_pagination container,other_params = {},paginator=@paginator
          return "" unless paginator and paginator.item_count > 0          
          if container.is_a? Hash            
            #paginator = other_params
            other_params = container            
            container = nil
          end
          other_params[:method] ||= :get unless container
          full_view = other_params.delete(:full_view) 
          method = other_params.delete(:method) || :xml_http_request
          object = other_params.delete(:object) || "post"
          show_border = (other_params.delete(:border) != false)
          render :partial=>'shared/show_pagination',
                :locals=>{'object'=> object ,'paginator'=>paginator,'name'=>'page','container'=>container,'url'=>other_params,
                      'method'=>method,'show_border'=>show_border,'full_view'=>full_view
          }   
      end
      

      def m_link name,link={},options=nil #links that look like the vertical menu 
          options = (options || {}).merge(:class=>'menu-like-links')
          #options[:onmouseover] = "$(this).down('div').addClassName"
          return link_to("<div>#{name}</div>",link,options)
      end          
      def n_link name,link={},options=nil
          options = (options || {}).merge(:class=>'bold-link-div')
          #options[:onmouseover] = "$(this).down('div').addClassName"
          return "<div style='border-bottom:1px solid #C0C0C0'>" + link_to("<div class='' style='font-size:8pt !important;margin-bottom:5px;margin-top:5px'>#{name}</div>",link,options) +
                 "</div>"     
      end
      def link_to_add_friend student,link_name=nil
          link_name ||= "Add #{student.f_name} as Your Friend"
          link_to_popup("<div>#{link_name}</div>",url_for_student(student,{:action=>'add_as_friend'}),
                                        :class=>'menu-like-links',:pop_options=>{:title=>"Adding  #{student.f_name} as Your Friend"})       
      end
      def link_to_remove_friend student,link_name=nil
            link_name ||= "Remove #{student.f_name} as Your Friend"
           link_to "<div> #{link_name} </div>",url_for_student(student,{:action=>'remove_as_friend'}),
                          :class=>'menu-like-links',:confirm=>["Remove Friend","Are you sure you want to remove #{student.f_name} as your friend ? "]
      end
      def link_to_blog 
        link_to "Blog","",:style=>'font-size:10pt;color:#394E8B; !important'
      end
      def link_to_bug_report name
          link_to_popup name,{:action=>'report_bug'}
      end
end

