require "json"

class Contacts
  class Gmail < Base
    URL                 = "https://mail.google.com/mail/"
    LOGIN_URL           = "https://www.google.com/accounts/ServiceLoginAuth"
    LOGIN_REFERER_URL   = "https://www.google.com/accounts/ServiceLogin?service=mail&passive=true&rm=false&continue=http%3A%2F%2Fmail.google.com%2Fmail%3Fui%3Dhtml%26zy%3Dl&ltmpl=yj_blanco&ltmplcache=2&hl=en"
    CONTACT_LIST_URL    = "https://mail.google.com/mail/?view=cl&search=contacts&pnl=a"
    
    PROTOCOL_ERROR      = "Gmail has changed its protocols, please upgrade this library first. If that does not work, contact lucas@rufy.com with this error"
    
    def real_connect
      postdata =  "ltmpl=yj_blanco"
      postdata += "&continue=#{CGI.escape(URL)}"
      postdata += "&ltmplcache=2"
      postdata += "&service=mail"
      postdata += "&rm=false"
      postdata += "&ltmpl=yj_blanco"
      postdata += "&hl=en"
      postdata += "&Email=#{CGI.escape(login)}"
      postdata += "&Passwd=#{CGI.escape(password)}"
      postdata += "&rmShown=1"
      postdata += "&null=Sign+in"
           
      time =      Time.now.to_i
      time_past = Time.now.to_i - 8 - rand(12)
      cookie =    "GMAIL_LOGIN=T#{time_past}/#{time_past}/#{time}"
      
      data, resp, cookies, forward, old_url = post(LOGIN_URL, postdata, cookie, LOGIN_REFERER_URL) + [LOGIN_URL]
      cookies = remove_cookie("GMAIL_LOGIN", cookies)
      
      if data.index("Username and password do not match")
        raise AuthenticationError, "Username and password do not match"
      elsif data.index("Required field must not be blank")
        raise AuthenticationError, "Login and password must not be blank"
      elsif data.index("errormsg_0_logincaptcha")
        raise AuthenticationError, "Captcha error"
      elsif data.index("Invalid request")
        raise ConnectionError, PROTOCOL_ERROR
      elsif cookies == ""
        raise ConnectionError, PROTOCOL_ERROR
      end
      
      until forward.nil?
        data, resp, cookies, forward, old_url = get(forward, cookies, old_url) + [forward]
      end
      cookies = remove_cookie("LSID", cookies)
      cookies = remove_cookie("GV", cookies)
            
      if resp.code_type != Net::HTTPOK
        raise ConnectionError, PROTOCOL_ERROR
      end
      p "DDDDDDDDDDDDDDDDDDDDD"
      p data
      
      @cookies = cookies

    end
    
  private
    
    def parse(data)      
      data.gsub!("\n","")
      data.gsub!("D([", "\nD([")
      data.gsub!("]);", "]);\n")
      data.gsub!("u003d", "=")
      data.gsub!("u002f", "/")

      parsed_data = []
      data.scan(%r{D\(\[(.*)\]\)}) do |match|
        parsed_data << JSON.parse("[#{match[0]}]") rescue next
      end
      
      @contacts = parsed_data.select{|d| d[0] == "cl"}.inject([]) do |a,d|
        a.concat(d.inject([]) do |ar,dr|
          ar.concat(dr.is_a?(Array) && dr[4] && !dr[4].empty? ? [[dr[3],dr[4]]] : [])
        end)
      end
    end
    
  end

  TYPES[:gmail] = Gmail
end
