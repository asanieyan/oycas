class MenuItem          

          def self.eval_name(name,binding)
              case name.class.to_s
                    when "Symbol"
                        return name.to_s.titleize
                    when "String"                                                 
                        return eval('"' + name + '"',binding)
              end                  
          end  
          def self.eval_sub_menu code,binding
                 return eval(code,binding)
          end        
          def self.eval_url(url,binding)
                if (url.is_a? String)                                     
                    return eval('"' + url + '"',binding)        
                end
                return url
          end
          attr_accessor :name,:url,:html,:sub_menus,:if_block   
          def initialize *args     
                args.flatten!       
                @name = args.shift                 
                @url = args.shift 
                @if_block = @url.delete(:if) rescue nil
                @depends_on_sub = @url.delete(:depends_on_sub) rescue nil
                @url = nil if @url and @url.empty?                
                @html = args.shift             
                @sub_menu_block = args.shift                                                
          end 
          def set_binding(binding)  
              return if @binding                        
              @binding = binding
              if @if_block
#                  p 'now'
#                  p if_block
                  @if_block = eval(@if_block,binding)
#                  p @if_block.to_s
                  return unless @if_block
              else
                  @if_block = true
              end
              @name = MenuItem::eval_name(@name,binding)
              @url = MenuItem::eval_url(@url,binding)                            
              if @sub_menu_block                  
                  add_sub_menu(MenuItem::eval_sub_menu(@sub_menu_block,binding))
              end
              if has_submenus? 
                @sub_menus = @sub_menus.inject([]) do |arr,s|
                        if s.is_a?(MenuItem) 
#                          p 'setting submenu bining ' + s.name
                          s.set_binding(binding);
#                          p 'evaluating submenu if block'
                          if s.if_block                  
#                            p "true so show submenu"
                            arr << s
                          end  
#                          p 'processing next'
                        end
                        arr
                end               
              elsif @depends_on_sub           
                @if_block = false
              end              
          end
          def has_submenus?
              return (@sub_menus != nil and !@sub_menus.empty?)
          end
          def add_sub_menu name,url=nil,html={}
              return unless name
              @sub_menus ||= []                          
              if name.is_a? MenuItem
                @sub_menus << name
              elsif name.is_a? Array and !name.empty?
                @sub_menus << [name]
                @sub_menus.flatten!
              else
                @sub_menus << MenuItem.new(name,url,html)
              end
          end
          alias add_submenu add_sub_menu
end