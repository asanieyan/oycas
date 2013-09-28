# Include hook code here
dir = File.expand_path(File.join(File.dirname(__FILE__),"lib"))    
Dir["#{dir}/**/*.rb"].each  do |f|
 require f 
end


ActiveRecord::Base.class_eval do 
  include OycasHelpers::EmailHelper
  include GUID
  include FieldTextSanitizer

end
ActionController::Base.class_eval do 
   include OycasHelpers::UrlRewrite
   include OycasHelpers::RenderHelper
   include OycasHelpers::EmailHelper
   include ContextMenuConstructor
end

ActionView::Base.class_eval do 
  include OycasHelpers::JavaScriptHelper
  include OycasHelpers::UrlHelper
  include OycasHelpers::TagHelper
  include OycasHelpers::RenderHelper
  include OycasComponents::LayoutComponents
  include OycasComponents::DropDownMenu
  include OycasComponents::GuiElements
  include OycasHelpers::EmailHelper
  include OycasHelpers::DateHelper
  include OycasHelpers::FormHelper

end