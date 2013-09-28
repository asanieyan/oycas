module OycasComponents
  module DropDownMenu
      def oycas_menus *args,&block
         if args.first.is_a? Array
           menu_items = args.shift
         else 
          menu_items = []
         end
         menu_selector = args.shift
         options = args.shift || {}
         html = "<table  cellspacing=0 cellpadding=0 class='top-v-align' style='padding:0;margin:0'><tr>"
         menu_selector[:main]
         main={:class=>menu_selector[:main].shift,:hover=>menu_selector[:main].shift,:active=>menu_selector[:main].shift}
         main[:active] ||= main[:hover]
         sub = {}
         if menu_selector[:sub] 
           sub = {:class=>menu_selector[:sub].shift,:hover=>menu_selector[:sub].shift,:active=>menu_selector[:sub].shift}
         end
         menu_cols = []
         if block_given?          
           block.call(menu_items)
         end
         menu_items.each  do |menu|           
           menu.set_binding(self.send(:binding))
           if menu.if_block           
            menu_cols << render_p("oycas_rhtml_components/drop_down_menu_base",{'menu'=>menu,'main'=>main,'sub'=>sub,'options'=>options})
           end
         end
         if options[:seperator]
           html << menu_cols.join("<td style='vertical-align:middle'>#{options[:seperator]}</td>")
         else
          html << menu_cols.join("")
         end
         html << "</tr></table>"
         html << javascript_tag("new JMenu('.#{main[:class]}','#{main[:hover]}','#{main[:active]}','.#{sub[:class]}','#{sub[:hover]}','#{sub[:active]}')")
         return html
      end    
  end
end