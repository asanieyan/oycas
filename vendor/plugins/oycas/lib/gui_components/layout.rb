module OycasComponents
  module LayoutComponents
      def oycas_include_tags
            stylesheet_link_tag("mainlayout.css","elements.css","components.css","vendor.css","vendor/#{@browser.name.to_s.downcase}.css") + 
            javascript_include_tag(:defaults,"nifty") + "\n" + <<-eof
               <link rel="shortcut icon" href="/images/favicon.gif?1181331917" type="image/gif?1181331917" />
               <!--[if lte IE 6]><script src="/javascripts/IEmarginFix.js?1181331917" type="text/javascript"></script> <![endif]-->            
               <!--[if gte IE 7]><script src="/javascripts/ie7/ie7-standard-p.js?1181331917" type="text/javascript"></script><![endif]-->
               <!--[if gte IE 5]><style>.ie-png-shade-fix-wrapper {left:30%;}</style><![endif]-->                                 
            eof
      end    
      def generate_oycas_layout(logo_url="#",&block)          
          render_p "oycas_rhtml_components/oycas_layout",{'logo'=>logo_url,'block'=>block}
      end
      def oycas_masthead logo_url="#",&block
        constant=[""]
        context=[""]
        yield(context,constant) if block_given?           
        html = ""
        html << "<div id='top-menu2' style='background-color:white;float:right;position:relative;top:15px;'>"
        html <<  constant.pop
        html << "</div>"        
        html << link_to(image_tag('/images/oycas.gif') + "beta",logo_url,:style=>"font-variant:small-caps;font-size:6pt;text-decoration:none;color:black")        
        html << "<div id='main-menu-row' class='' style=';background-color:#00C8FF'>"
        html << context.pop
        html << "</div>"
        return html
      end
      #the standard menus 
      def oycas_access_constant_menu 
          oycas_menus({:main=>%w(item top-item-hover top-item-active),
                  :sub=>%w(top-submenu-item sub-menu-item-hover)},
                  {:s_indicator=>'/images/trismall.gif',   
                   :seperator=>"<div style='color:#DDDDDD !important'> | </div>",
                   :s_class=>'top-drop-down'}) do |menus|                   
                     menus << MenuItem.new('login',"/access/login")
                     menus << MenuItem.new('register',"/access/register")
                     menus << MenuItem.new('tour',"/access/tour")
                     url,options = help_url_for('h0')
                     options[:pop_options].update(:onclose=>"$('top_help').parentNode.removeClassName('top-item-active')")
                     options[:id] = "top_help"
                     menus << MenuItem.new('help',url,options)
                   end        
      end
      def oycas_session_constant_menu
          oycas_menus({:main=>%w(item top-item-hover top-item-active),
                  :sub=>%w(top-submenu-item sub-menu-item-hover)},
                  {:s_indicator=>'/images/trismall.gif',  
                  :seperator=>"<div style='color:#DDDDDD !important'> | </div>",
                   :s_class=>'top-drop-down'}) do |menus|                  
                        if @admin
                                menus << MenuItem.new("admin","/admin/admins")
                        end
                        
                        unless @I.am_admin?
                               menus << MenuItem.new("home","/my/home")   
                               menus.last.add_sub_menu('My Friends',"/my/friends")   
                               menus.last.add_sub_menu("-")
                               menus.last.add_sub_menu('My Photo',"/my/photo")   
                               menus.last.add_sub_menu("-")
                               menus.last.add_sub_menu('My Binder',"/my/binder")  
                               menus << MenuItem. new("inbox#{'(' + @my.num_unread_messages.to_s + ')' if @my.num_unread_messages > 0}", '/my/messages')
                               menus.last.add_sub_menu('Compose',"/my/compose")
                               menus << MenuItem.new("classifieds","/classifieds/network/#{@my.default_school.network.name}/browse")
                               menus.last.add_sub_menu("My Posts",'/classifieds/my_posts')
                               menus << MenuItem.new('my school', url_for_school(@my.default_school))
                               courses = false
                               @my.schools.each do |school|
                                    @my.klasses_at(school).each do |klass|
                                        courses = true
                                        name = klass.name
                                        if params[:cid] == klass.guid.to_s
                                           name = "-> " + name
                                         end                                 
                                         menus.last.add_sub_menu(name,url_for_klass(klass))
                                    end
                               end                                    
                               menus.last.add_sub_menu("-") if courses
                               @my.schools.each do |school|
                                    menus.last.add_sub_menu(school.name,url_for_school(school))
                               end     
                               
                        end       
                       menus << MenuItem.new('logout', '/access/logout')
                       url,options = help_url_for('h1')
                       options[:pop_options].update(:onclose=>"$('top_help').parentNode.removeClassName('top-item-active')")
                       options[:id] = "top_help"
                       menus << MenuItem.new('help',url,options)

                  end        
      end      
      def oycas_session_context_menu
            oycas_menus(@controller.vendor_top_menu_items,
                        {:main=>%w(main-menu-item main-menu-item-hover main-menu-item-active),
                         :sub=>%w(sub-menu-item sub-menu-item-hover)},
                         {:s_indicator=>"/images/tri_black.gif",
                          :s_class=>"sub-menu",
                          :seperator=>"<div style='color:#000000;'> | </div>"}
                         
               )        
      end
  end
end