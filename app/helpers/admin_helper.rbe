module AdminHelper
  def select_dates_for_semester semester,date
    
    if semester.start_date.month > semester.end_date.month
      months = (semester.start_date.month..12).to_a + (1..semester.end_date.month).to_a
    else
      months = (semester.start_date.month..semester.end_date.month).to_a 
    end
    month_names = []
    months.uniq.each do |month_number|
      month_names << ["#{month_number} - #{Date::MONTHNAMES[month_number]}",month_number]      
    end
    select_tag "#{date}[month]",options_for_select(month_names,(semester.send(date.to_sym).month rescue ""))
    
  end
  def show_admin_list list,form_id
       select_tag "admin_id",options_for_select(list.map{|a| ext = (a.id == @admin.id ? " (That's you)" : "");[a.email + ext,a.id.to_s]},params[:admin_id]),:size=>'10',:onclick=>"$('#{form_id}').submit();"
  end
  def link_to_classified post
      link_to "classified: " + truncate(post.title,50),"/classifieds/network/#{post.network.name}/show/#{post.id}"  
  end
  def album_url photo
      url_for_student(photo.student,:action=>'view_album',:a=>photo.album.guid)
  end
  def render_violation_summary_for student
       sum = "\n"
       student.violations.stats.each_violation_type do |v,s|
            sum << "\t- #{v.capitalize} Violations:\n"
            s.each do |r|
            sum << "\t\t* #{r['reason'] +'('+ pluralize(r.num.to_i,'report') + ')'}\n"               
            end
        end
        return sum
  end
  def to_admin_time time
       time.strftime("%b/%d/%y")
  end
  def show_offensive_photo report
       photo = report.item
       if photo 
         <<-"EOF"      
         <div>
         Owner: #{link_to_student photo.student}<br>                
                  #{link_to image_tag(photo.album.get_medium_photo(photo),:style=>'padding:5px;border:1px solid #C0C0C0'),
                      url_for_student(photo.student,:action=>'view_album',:a=>photo.album.guid,:p=>photo.guid)}
          </div>
         EOF
       else
         report.resolved_comments
       end
  end
end
