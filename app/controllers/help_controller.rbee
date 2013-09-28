class HelpController < ApplicationController

  def render_menus
        add_menu('Home',"/help")        
  end


  skip_before_filter :authorize,:only=>%w(h0 mail_to_us)
  def h0
    render_help params[:id],"reg_help.yml"
  end
  def h1    
    render_help params[:id],"student_help.yml"    
  end
  def mail_to_us
    render_p 'help/mail_to'
  end
  private
  def render_help id,help_file,render_layout=false
     #open YAML file, read in appropriate document
      @topic_id = id || "Help_Home_Page"
      @help_home_page = (@topic_id == "Help_Home_Page")
      @current_document = nil
      @subsections = Array.new
      begin
      File.open("./lib/help_files/#{help_file}") do |yamlfile|
        YAML.each_document(yamlfile) do |doc|
          if @topic_id == "Help_Home_Page" then
            if doc["title"] != "Help_Home_Page" then
              @subsections << doc["title"] 
              @subsections.sort! { |x,y| x <=> y }             
            else
              @current_document = doc
            end
          else
            if doc["title"] == @topic_id then
              @current_document = doc
              break
            end
          end
        end
      end
      rescue Exception => e
  #      puts e
      end
      render :template=>"help/help",:layout=>render_layout;    
  end  
end
