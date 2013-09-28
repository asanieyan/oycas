module ContextMenuConstructor    
    def self.included base                        
        base.class_eval <<-eof                            
          attr_accessor :vendor_top_menu_items
          before_filter :reset_menus
          before_filter :prepare_to_render_menus
          private                
            def reset_menus                                   
              @vendor_top_menu_items = []
            end
            def prepare_to_render_menus                                                      
                return if request.xhr? or component_request? != nil     
                render_menus
            end
            def render_menus
            
            end
            def add_menu *args                                                                                           
                @vendor_top_menu_items ||= []
                @vendor_top_menu_items << MenuItem.new(args)
                return @vendor_top_menu_items.last
            end
          public
        eof
    end  
end