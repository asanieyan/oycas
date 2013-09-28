module AccessHelper
  def draw_maps image,maps=[]
    
    id = "m" + rand(10000).to_s
    html = image_tag "/images/tour/#{image}.gif",:usemap=>"##{id}",:style=>'border:none'
    return html if maps.empty?
    html << "<map name='#{id}' id='#{id}'>"
    maps.in_groups_of(3,false) do |image_id,cord,desc|
        next if cord == ""
        html << "<area href='#' onclick='return false;' id='#{image_id}' shape ='rect' coords ='#{cord.gsub(/ /,',')}' />"
    end    
    html << "</map>"
    
    maps.in_groups_of(3,false) do |image_id,cord,desc|
        next if cord == ""
        html << "<div id='#{image_id}_proto'  style='padding:7px;padding-bottom:0;' class='transparent-shade'>"
        html << "<div class='status-box' style='width:450px'>"
        html << "<div class='centered' style='padding:5px;display:table;#{@browser.sel_for({:msie=>''},'background-color:#EEEEEE')}'>" + image_tag("/images/tour/#{image_id}.gif") + "</div>"
        html << "<br><div class='dark-gray' style=''>"
        html << render(:inline=>desc)
        html << "</div>"
        html << javascript_tag("new Tooltip('#{image_id}', '#{image_id}_proto')")
        html << "</div>"
        html << "</div>"        
    end    
    return html
    
  end
end
