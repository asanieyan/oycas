module OycasHelpers
  module TagHelper
      def hr style=""
         @browser.sel_for({:msie=>"<div class='thin' style='#{style}'></div>"},"<hr class='thin' style='#{style}' />")
      end
      def table_tag options={}
        html = ""
        num_of_col_per_row = options.delete(:cols) || 2
        
        yield(elements = []) 
        return html if elements.empty?
        options[:table] ||= {}
        options[:table][:cellspacing] ||= 0
        options[:table][:cellpadding] ||= 0        
        row = 0
        elements.in_groups_of(num_of_col_per_row) do |cols|                 
          row_content = ""
          row += 1
          cols.each_with_index do |col,i|
            col_options = options.delete("col#{i+1}".to_sym) || {}
            if col.is_a? Array 
              if  col.last.is_a? Hash
                col_options.update(col.pop)
              end
              col = col.join("\n")
            else           
              col ||= ""            
            end
            row_content << content_tag(:td,col,col_options)           
          end          
          html << content_tag(:tr,row_content,options.delete("row#{row}".to_sym))         
          
        end   
        content_tag(:table,html,options.delete(:table))
      end
      def flaggy_text_field(name, content = nil, options = {})        
            text_field_name = name 
            text_field_value = content                            
            text_field_options = options                        
            if (banner = text_field_options.delete(:flag) || text_field_options.delete(:banner)) 
                options = {:reset=>false}.merge(options)
                if  (text_field_value || "").size == 0
                     text_field_value = banner
                     text_field_options[:class] = 'flagg-text-box ' + (text_field_options[:class] || "")
                 
                end  
                if options[:reset]               
                 text_field_options[:onfocus] = 'this.value="";$(this).removeClassName("flagg-text-box");' + (text_field_options[:onfocus] || "")                  
                else
                  text_field_options[:onfocus] = update_page do |p|
                                                    p << <<-"end_eval"    
                                                          if ($(this).hasClassName('flagg-text-box')) {
                                                               this.value="" 
                                                               $(this).removeClassName("flagg-text-box")                                                         
                                                          }                                      
                                                        end_eval
                                                 end   
                                                 
                end
                text_field_options[:onblur] =  "if (this.value.blank()){this.value='#{banner}';$(this).addClassName('flagg-text-box')};" +(text_field_options[:onblur] || "")                             
            end
            return  text_field_tag(text_field_name,text_field_value,text_field_options)           
      end
      def wysi_area name,value="",size=nil        
          html = '<script type="text/javascript" src="/wys/wysiwyg.js"></script>'
          html << text_area_tag(name,value)
          html << update_page_tag do |p| 
                      if size 
                          width,height = size.split("x")
                          p << "wysiwygWidth = #{width}" if width.to_i > 0
                          p << "wysiwygHeight = #{height}" if height.to_i > 0
                      end
                      
                      p << "generate_wysiwyg('#{name}');"
                  end

      
      end
      def text_area_tag(name, content = nil, options = {}) 
          rich = options.delete(:rich)
          return wysi_area(name,content,options[:size]) if (rich)          
          if (maxlength = options.delete(:maxlength).to_i) > 0
              options[:onkeypress] = options[:onkeyup] = update_page {|p|
                              p << <<-"end_script"                                   
                                   if (this.value.length >= #{maxlength}) {
                                    this.value = this.value.truncate(#{maxlength}-1,"")                                   
                                   }
                                     
                              end_script
              } + ";" + (options[:onkeypress] || "") 
          end
          super(name,content,options)
          
      end
      def search_box name,value="",options={}
          render_p 'shared/search_box',{'name'=>name,'content'=>value,'options'=>options}
      end    
      #returns a select tag with pretty options
      def custom_select_tag container = [],selected="", onchange = nil
            return if container.empty?            
            
#            options.each do |k,v|
#              options.delete(k) if k =~ /on\w+/
#            end
            display_text = ""
            function_name = "F" + rand(10000000).to_s
            
            options_box_id = rand(900000)
            select_box_id = options_box_id + rand(10000)
            select_text_id = select_box_id + 1
            
            option_tags = container.inject([]) do |select_options,element|
               
               if element.is_a? Array
                 option_value = element.pop.to_s
                 option_text = element.pop.to_s
               else
                 option_value = option_text = element.to_s
               end
               css_class = ""
               if selected.to_s == option_value
                  display_text = option_text.to_s
                  css_class = "selected"                  
               end
               select_options << link_to(("<div style='padding:2px'>" + option_text + "</div>"),nil,:class=>css_class,:value=>html_escape(option_value),
               :style=>'text-decoration:none !important',:onclick=>"$('#{select_text_id}').innerHTML = $(this).down('div').innerHTML;$('#{options_box_id}').hide();#{function_name}($(this).readAttribute('value'),'#{select_text_id}');return false;")
                
            end            
            html = javascript_tag("var #{function_name} = function(value,text){" + (onchange || "") + "}")
            html << <<-eof
                <table id='#{select_box_id}' class='custome-select-box top-v-align' cellspacing=0 cellpadding=0>
                  <tr>
                      <td>
                          #{link_to '<div>' + display_text + '</div>','#',:id=>select_text_id,:onclick=>"$('#{options_box_id}').toggle();",:style=>'text-decoration:none !important'}
                      </td>
                      <td style='text-align:right;vertical-align:bottom;'>
                        #{link_to(image_tag('/images/custom_select_arrow.gif'),'#',:onclick=>";$('#{options_box_id}').toggle();")}
                       </td>
                   </tr>
                   <tr>
                      <td colspan=2>
            eof
            html << "<div id='#{options_box_id}' class='custom-select-options' style='display:none'>" + option_tags.join("") + "</div>"
            html << "</td></tr></table><br>"
            html.gsub(/\s+/,' ')
            html << javascript_tag("$('#{options_box_id}').hideIfNotClickedOn($('#{select_box_id}').descendants())")
            html           
#            #content_tag(:div, nil,{ "name" => name, "id" => name }.update(options))

      end
  end
end