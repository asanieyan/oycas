module OycasComponents
  module GuiElements
   def what_to_do_box 
     lis = []
     yield(lis)
     html = ""
     lis.each do |li|
       border =  lis.last == li ? "" : "border-bottom:1px solid #C0C0C0"
       list_item = content_tag(:li,content_tag(:div,li,:class=>"",:style=>'padding-top:0 !important;padding-bottom:0 !important;margin-top:0 !important;margin-bottom:0 !important;color:black'),:style=>"font-weight:bold;font-size:10pt;")
       html << content_tag(:ul,list_item,:class=>"liststyle1",:style=>"padding-top:0 !important;padding-bottom:0 !important;margin-top:5px !important;margin-bottom:5px !important")
       #html << "<div class='centered' style='width:200px;border-top:1px solid #C0C0C0'></div>"  unless  lis.last == li   
     end
     html = content_tag(:div,html,:class=>'yellow-box ',:style=>"margin:0 !important")
     return html     
   end
   def dashboard options={} 
      links = []
      yield(links)
      return "" if links.empty?
      links = links.join(" | ")
      content_tag(:div,links,:id=>"dashboard",:class=>"small-link-div",:style=>"padding-bottom:2px;text-align:#{options[:align] || 'right'};margin-bottom:20px;color:#C0C0C0;border-bottom:1px solid #C0C0C0")
     
   end
    def create_flex_box title,flex=false,flex_options={},&block
        flex_id = title.downcase.gsub(/ /,'_')
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
            flex_content = flex_content(:div,flex_content,:class=>"status-box")
          end
          inside_css_options[:style] ||= ""
          if !dashboard_links.empty?
             inside_css_options[:style] =';padding-top:2px' + inside_css_options[:style]
             content << create_flex_dashboard(dashboard_links)
          end
          if !label.empty?
             inside_css_options[:style] =';padding-top:2px' + inside_css_options[:style]
             content << create_flex_label(label.join(""))
          end
          content <<  "<div style='clear:right;margin-bottom:10px'></div>" + flex_content
          content = title + content_tag(:div,content,inside_css_options.update(:class=>"flex-in",:id=>"#{flex_id}_in"))
          content << javascript_tag("new Flexer('#{flex_id}',#{options_for_javascript(flex_options)})") if flex
          return concat(content,block.binding)
        end
        return title
    end
    def report_form item,&block      
        reasons = [["Pick one...",-1]] + ReportReason[item].map{|s| [s,s.id]}
       
        html = form_tag({},{:onsubmit=>update_page do |p|
                                          p << "if($('reason').selectedOption() == -1 || $('comments').value.blank()) {"
                                            p.message.show({:emsg=>'Please provide an explanation for this report.'},{:hide=>true})                                              
                                            p << "return false; }"
                                        end })          

        
        
        html << "<div class='status-box'>"
        if block_given?
            html << capture(&block)
        end
        html << "<div id='emsg'></div>"
        html << "<table cellspacing=0 cellpadding=0><tr><td class='bold-gray'  style='vertical-align:top'> Reason: </td><td>"          
        html << select_tag("reason",options_for_select(reasons),
                :onclick=><<-EOF                            
                            if($('reason').selectedIndex  > 0)
                                $('comments').disabled = false
                            else
                                $('comments').disabled = true
                         EOF
              )
        html << "</td></tr><td class='bold-gray' style='vertical-align:top'> Your Comment: <div style='font-weight:normal'>(Required)</div> </td><td>"
        html << text_area_tag("comments","",:size=>'35x5',:disabled=>true) 
        html << "</td></tr></table>"        
        html << "<div style='text-align:right'>"
        html << link_to_function('Cancel',"Pop.close()",:style=>'padding-right:10px') 
        html << submit_tag("Submit Report")
        html << "</div></div></form>"
        return concat(html,block.binding) if block_given?
        return html
    end
    def select_visibility name,value=0,html_options={},&block

        #min selectable options
        #default option
        #and name 
        value = value.to_i
        seloptions = []   
        Student::VisibilityOptions.each_with_index do |option,index|
                  if block_given?
                   option = block.call(option)
                  end                    
                  seloptions << [option,index]
        end               
        min = html_options.delete(:min) || 0
        max = html_options.delete(:max) || seloptions.size - 1
        min =  0 if  (min < 0 or min > seloptions.size - 1)
        max =  seloptions.size - 1 if (max < 0 or max > seloptions.size - 1) 
        
        value =  min if (value < min or value > max)          
        seloptions = seloptions[min..max]

        html_options[:style] = "font-size:8pt"
        select_tag name,options_for_select(seloptions,value),html_options
    
    end      
   private 
      def create_flex_dashboard array_of_links       
          html = content_tag(:div,array_of_links.join(" | "),:class=>"small-link-div",:style=>"float:right")
      end
      def create_flex_label label
        return content_tag(:div,label,:class=>'normal-gray')
      end      
  end
end