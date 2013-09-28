class Vendor
    
    attr_accessor :base,:vendor,:name,:full_name,:version
    def initialize user_agent        
        if user_agent =~ /MSIE/
            @name = :MSIE 
            @full_name = "Microsoft Internet Explorer"            
            @version = user_agent.match(/MSIE (\d+\.\d+);/)[1]
        elsif user_agent =~ /Firefox/
            @name = :FireFox
            @version = user_agent.match(/Firefox\/((\d|\.)*)/)[1]
            @full_name = "Mozilla Firefox"    
        end
    end
    def is_not? b_name
      return !is_a?(b_name)
    end
    def is_a? b_name
        return name.to_s.downcase == (b_name.to_s.downcase rescue "")
    end
    alias is_a is_a?
    alias is is_a?
#    def if_is *args
#        default_value = args.last.is_a?(String) ? args.pop : ""
#        values = args.inject({}) do |h,v|
#            k,v = v.shift
#            h[k] = v
#            h
#        end        
#        sel_for values,default_value
#    end
    def sel_for(browser_values,default_value="") 
        browser_values.stringify_keys!
        ret_val = browser_values[self.name.to_s.downcase]
        ret_val = default_value unless ret_val   
        return ret_val
    end
    alias if_is sel_for
end
