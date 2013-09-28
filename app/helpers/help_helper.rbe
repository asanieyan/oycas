module HelpHelper

  def link_to_topic (link_text, topic_name=nil)
    topic_name ||= link_text
    link_to_remote link_text, :update => "help", :url => { :controller => 'help', :action => params[:action], :id => topic_name}
  end
  def mail_to_us
    link_to 'info@oycas.com', 'mailto:info@oycas.com'
#      link_to_remote "info@oycas.com",:url=>{:action=>"mail_to_us"},
#                                      :update=>'help'      
  end

end
