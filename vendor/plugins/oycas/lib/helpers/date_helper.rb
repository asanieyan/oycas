module OycasHelpers
  module DateHelper
      def forum_time_helper(time,tz,options={})
                    date_only = options.delete(:date_only) || false
                    current_zone_time = tz.utc_to_local(Time.now.utc)                    
                    date,time = case time                                    
                          when current_zone_time.ago(2.hours)..current_zone_time
                              [distance_of_time_in_words(time,current_zone_time) + " ago",""]
                          when current_zone_time.at_midnight..current_zone_time                                   
                              ["Today", "at #{time.strftime('%I:%M %p').gsub(/^0(\d)/,'\1').downcase}"]
                          when current_zone_time.yesterday.at_midnight..current_zone_time
                              ["Yesterday","at #{time.strftime('%I:%M %p').gsub(/^0(\d)/,'\1').downcase}"]
                          when current_zone_time.beginning_of_year..current_zone_time
                              [time.strftime('%b %d').gsub(/0(\d)/,'\1'), "at #{time.strftime('%I:%M %p').gsub(/^0(\d)/,'\1').downcase}"]
                          else
                              [time.strftime('%b %d, %Y').gsub(/0(\d),/,'\1,'),"at #{time.strftime('%I:%M %p').gsub(/^0(\d)/,'\1').downcase}"]
                     end 
                     date + (date_only ? "" : (" " + time))
      end
      alias time_helper forum_time_helper
      alias humen_time_for forum_time_helper 
      def to_my_human_time(time_in_utc,options={})
        humen_time_for(@my.time(time_in_utc),@my.tz,options)
      end
      def day_grouped_time_helper(time1)
          time1 = @my.time(time1)
          current_time_at_my_timezone = @my.time(Time.now.utc)
          
          if time1.to_date == current_time_at_my_timezone.to_date
               time1.strftime("Today %A, %B %d")
          else
               time1.strftime("%A, %B %d")        
          end      
      end      
  end   
end