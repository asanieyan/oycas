module FacebookHelper
    def link_to_app(name, options = {}, html_options = {}, *parameters_for_method_reference)
          #assuming options is string for now          
          require 'uri'
          parsed = URI.parse(url_for(options))
          parsed = parsed.path.to_s + (parsed.query ? "?#{parsed.query}" : "")          
          options = "login_to_oycas?url=#{url_encode(parsed)}"
          link_to name,options,{:target=>"_blank"}.update(html_options)
    end  
    def image_tag(source, options = {})
        require 'uri'
        source = URI.join(request.protocol + request.host_with_port,source).to_s       
        super source,options
    end
    def stylesheet_link_tag *sheets
        html = "<style>"
        sheets.each do |sheet|

            File.open("public/stylesheets/#{sheet}","r") do |f|
              html << f.read
            end
        end
        html << "</style>"      
    end
end
