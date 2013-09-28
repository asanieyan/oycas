module MyHelper
  def self.render_course_items    
        return ""
        <<-"end_eval"                                      
          courses =  @my.schools.inject([]) do |arr,s|
                  set_of_class = []
                  @my.klasses_at(s).each do |klass| 
                      name = klass.name
                      if params[:cid] == klass.guid.to_s
                         name = "-> " + name
                      end
                      set_of_class << MenuItem.new(name,url_for_klass(klass))
                  end
                  arr << set_of_class unless set_of_class.empty?
                  arr                                                                                          
          end                                                                     
          courses = courses.inject([]){|classes,set_of_class| 
              classes += set_of_class
              classes << "-"
              classes
          }          
          courses.pop if courses.last == "-"
          if not courses.empty?
              courses << MenuItem.new("-")
              courses << MenuItem.new("Register",url_for_school(@my.default_school,:action=>"course_catalouge"))             
          end
          courses.empty? ? nil : courses
        end_eval
  end
  def link_to_mini
      link_to_function "Mini-Profile",'editProfileTabs.gotoTab("Profile Privacy")',{:class=>'small-link-div'}
  end
  def get_recipient_list(id)
    recs = StudentMessage.find(:all, :conditions=>["message_id=?",id])
    recipient_list = Array.new
    recs.each do |r|
      if r.recipient_id.to_s != @me.guid.to_s then
        recipient_list << getStudentName(r.recipient_id)
      end
    end
    return recipient_list
  end
  def message_listing_date(date)
      if date.year == Time.now.year
        date.strftime("%b %d")
#        date.to_s
      else
        date.strftime("%b %d, %Y")
      end
      return @my.time(date).strftime("%b %d, %Y")      
  
  end
  def formatDateTime(dateobj)

    if dateobj != nil then
      return dateobj.strftime("%I:%M%p").downcase + " " + dateobj.strftime("%B %d, %Y")
    else
      return nil
    end
  end


end
