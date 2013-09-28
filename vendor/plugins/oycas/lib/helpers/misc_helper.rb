module OycasHelpers
  module RenderHelper
    def render_p name,variables={}
        render :partial=>name,:locals=>variables
    end
    def render_html name,variables={}
          render_to_string :partial=>name,:locals=>variables    
    end    
  end
  module FormHelper
      def submit_tag(value = "Save changes", options = {})
          options[:class] = options[:class] || "button-link"
#          disable = options.delete :disable
#          if disable == true
#            options["disable_with"] = value unless options["disable_with"]
#          end
          super value,options
      end    
  end
end