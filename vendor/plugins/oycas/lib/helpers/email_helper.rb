module OycasHelpers
  module EmailHelper
    class EmailHelper
        ValidEmailPatten = /^[\w-]+(\.[\w-]+)*@([a-z0-9-]+(\.[a-z0-9-]+)*?\.[a-z]{2,6}|(\d{1,3}\.){3}\d{1,3})(:\d{4})?$/
        def self.valid_format?(address)
            return true if address.downcase.match(ValidEmailPatten)
            return false
        end
        def self.get_domain(address)          
            return address.match(/\w+\.\w+$/).to_s
        end      
        def self.get_username(email)
          
        end
    end
  end
end