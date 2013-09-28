require 'csv'

class Contacts
  class Yahoo < Base
    URL                 = "http://mail.yahoo.com/"
    LOGIN_URL           = "https://login.yahoo.com/config/login"
    CONTACT_LIST_URL    = "http://address.yahoo.com/index.php?VPC=import_export&A=B&submit[action_export_yahoo]=Export%20Now"
    PROTOCOL_ERROR      = "Yahoo has changed its protocols, please upgrade this library first. If that does not work, contact lucas@rufy.com with this error"
    
    def real_connect
      postdata =  ".tries=2&.src=ym&.md5=&.hash=&.js=&.last=&promo=&.intl=us&.bypass="
      postdata += "&.partner=&.u=4eo6isd23l8r3&.v=0&.challenge=gsMsEcoZP7km3N3NeI4mX"
      postdata += "kGB7zMV&.yplus=&.emailCode=&pkg=&stepid=&.ev=&hasMsgr=1&.chkP=Y&."
      postdata += "done=#{CGI.escape(URL)}&login=#{CGI.escape(login)}&passwd=#{CGI.escape(password)}"
      
      data, resp, cookies, forward = post(LOGIN_URL, postdata)
      
      if data.index("Invalid ID or password")
        raise AuthenticationError, "Username and password do not match"
      elsif data.index("Sign in") && data.index("to Yahoo!")
        raise AuthenticationError, "Required field must not be blank"
      elsif data != ""
        raise ConnectionError, PROTOCOL_ERROR
      elsif cookies == ""
        raise ConnectionError, PROTOCOL_ERROR
      end
      
      data, resp, cookies, forward = get(forward, cookies, LOGIN_URL)
      
      if resp.code_type != Net::HTTPOK
        raise ConnectionError, PROTOCOL_ERROR
      end
      
      @cookies = cookies
    end
    
  private
    
    def parse(data)
      data = CSV.parse(data)
      col_names = data.shift
      @contacts = data.map do |person|
        [[person[0], person[1], person[2]].delete_if{|i|i.empty?}.join(" "), person[4]] unless person[4].empty?
      end.compact
    end
    
  end

  TYPES[:yahoo] = Yahoo
end
