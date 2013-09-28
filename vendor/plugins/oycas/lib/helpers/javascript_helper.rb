module OycasHelpers 
  module JavaScriptHelper
      #return the javascript method for a custom confirm box      
      def popup(window,options={})
          #extract the popup window options 
          if window[:size]
             width,height = (window.delete(:size) || "").split("x")           
          else
            width = window.delete :width
            height = window.delete :height
          end           
           win_options = {}
          title = window.delete(:title)                            
          url = url_for window.delete(:url) 
          onclose = window.delete(:onclose)       
          onpop = window.delete(:onpop)
          win_options['fixed'] =  window.delete(:fixed) || false
          win_options['height'] = "'" + height + "px'" if height
          win_options['width'] = "'" + width + "px'" if width
          win_options['title'] = "'#{title}'" if title
          win_options['url'] = "'" + url + "'"
          win_options['onclose'] = "function(){#{onclose}}" if onclose
          win_options['onpop'] = "function(){#{onpop}}" if onpop
          win_options['removeCanvas'] = window.delete(:remove_canvas) || false
        
          win_options = options_for_javascript(win_options)

          
          options = options_for_ajax options           
          return "Pop.up(#{win_options},#{options})"
      end
      def link_to_popup name,options={},other_options={}
          popup_options, ajax_options = extract_popup_options(options,other_options)
          popup_options[:title] ||= name
          x = link_to(name,'#',other_options.update(:onclick=>update_page{|p| 
                      p << popup(popup_options,ajax_options) + ";return false;"
          }))
      
      end
      def close_pop name='Cancel'
          link_to_function "Cancel","Pop.close()"
      end
      def button_to_popup(name, options = {}, other_options = {})
          popup_options, ajax_options = extract_popup_options(options,other_options)
          popup_options[:title] ||= name
          x = button_to(name,'#',other_options.update(:onclick=>update_page{|p| 
                      p << popup(popup_options,ajax_options) + ";return false;"
          }))
                
      end           
      def extract_popup_options(options,other_options)
          popup_options = {:url=>options}
          popup_options.update(other_options.delete(:pop_options) || {})   
#          p    popup_options  
          ajax_options = other_options.delete(:ajax) || {}
          
          return   popup_options, ajax_options         
      
      end
      def generate_msg             
              update_page_tag{|page|  
                           page.message.show(flash[:system_msgs].to_json,(flash[:system_msg_options]).to_json)
              }         
      end
      def confirm(*options)
          title = options.shift
          message = options.shift
          pop_options = options.shift
          joptions = ({:title=>title,:message=>message}.merge(pop_options || {})).to_json
          "Confirm(#{joptions})"
        end    
        #uses the nifty.js library to created rounded div
        def roundedDIV *args
          part = args.pop[:only] if args.last.is_a? Hash
          
          java_params = args.inject([]) do |params,param|
              params << "'" + param + "'";  
              params
          end
          java_params = java_params.join(",")
          method =  unless part
                       "Rounded"
                    else
                       "Rounded" + part.to_s.capitalize
                    end                  
          javascript_tag "if(NiftyCheck()){#{method}(" + java_params + ");}"        
        end
  end
end