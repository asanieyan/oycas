module SchoolHelper
  def semester_count_down big,small
     big = big.to_s
     small = small.to_s
     font_size = if big.size > 3
                  30
                 else
                  60      
                 end
     content_tag(:div,big,:style=>"text-align:center;font-size:#{font_size}pt",:class=>"orange") + 
     content_tag(:div,small,:style=>"text-align:center;font-variant:small-caps",:class=>"dark-bold-gray") 

  end
  def difference_of_time_in_days from,to
    (to.to_date-from.to_date).to_i
  end
  def count_down_days_till time,count_month=false,from=Time.now.utc
      if time
        if not count_month
          day = (from-time).to_i / 60 / 60 / 24

          return day
        end
        marker_time = from
        days = 0
        months = 0
        while marker_time.to_date < time.to_date do
          if marker_time.beginning_of_month.to_date == marker_time.to_date 
            months += 1
          else            
            days += (marker_time.at_end_of_month - marker_time).to_i / 60 / 60 / 24
            
          end
          marker_time = marker_time.next_month.beginning_of_month
        end
        return months,days            
      end         
      return nil
  end
  def countdown_widget2 days
    
  end
  
end
