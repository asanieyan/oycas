ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  
  # Sample of regular route:
  # map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  # map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # You can have the root of your site routed by hooking up '' 
  # -- just remember to delete public/index.html.
  # map.connect '', :controller => "welcome"

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  
  # Install the default route as the lowest priority.
#  map.classified_category 'classifieds/:network/category/:category/:action/:id', :controller=>'classifieds'                                                    
  map.classified_category 'classifieds/:network/:category/postings', :controller=>'classifieds',:action=>'postings'
  map.classified_category 'classifieds/network/:network/:action/:id', :controller=>'classifieds'
  
  map.connect 'classifieds/:action/:id', :controller=>'classifieds'
      
  map.klass  'class/:cid/:action/:id', :controller=>'klass'   ,
                                       :requirements=>{:cid=>/\d+/}  
  map.klass2 '/class/:class_name/:division/:action/:id', :controller=>'klass'

  map.course 'course/:courseid/:action/:id', :controller=>'course'  
  map.school 'school/:schid/:code/:action/:id', :controller=>'school'
  map.connect 'student/:sid/:action/:id' , :controller=> 'student'
#  map.connect ':controller/:action/:id.:format'
 
  map.connect ':controller/:action/:id'  
  map.connect '', :controller=>'access'

end
