module StudentQuery
    def fake
        @fake_students ||= find(:all,:conditions=>"students.rank LIKE 'dummy'")
    end
    def real
         @real_students ||= find(:all,:conditions=>"students.rank <> 'dummy'")
    end    
    def active        
        @active_students ||= find(:all,:conditions=>"students.account_status LIKE 'active'")
    end
    #all the method below the students are active
    def who_match options          
          if  options[:conditions]    
              options[:conditions] = [sanitize_sql(options[:conditions] || "") , "students.account_status LIKE 'active'"].join(" AND ")
          else
               options[:conditions] = "students.account_status LIKE 'active'"
          end
          find(:all,options)          
    end            
end