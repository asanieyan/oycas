class Contacts
  class Hotmail < Base
    URL                 = "http://www.hotmail.com/"
    OLD_CONTACT_LIST_URL = "http://%s/cgi-bin/addresses"
    NEW_CONTACT_LIST_URL = "http://%s/mail/GetContacts.aspx"
    COMPOSE_URL         = "http://%s/cgi-bin/compose?"
    PROTOCOL_ERROR      = "Hotmail has changed its protocols, please upgrade this library first. If that does not work, report this error at http://rubyforge.org/forum/?group_id=2693"
    PWDPAD = "IfYouAreReadingThisYouHaveTooMuchFreeTime"
    MAX_HTTP_THREADS    = 8
    
    def real_connect
      @use_new_contact_url = false
      
      data, resp, cookies, forward = get(URL)
      data, resp, cookies, forward = get(forward, cookies, URL)
      
      postdata =  "PPSX=#{CGI.escape(data.split("><").grep(/PPSX/).first[/=\S+$/][2..-3])}&"
      postdata += "PwdPad=#{PWDPAD[0...(PWDPAD.length-@password.length)]}&"
      postdata += "login=#{CGI.escape(login)}&passwd=#{CGI.escape(password)}&LoginOptions=2&"
      postdata += "PPFT=#{CGI.escape(data.split("><").grep(/PPFT/).first[/=\S+$/][2..-3])}"
      
      form_url = data.split("><").grep(/form/).first.split[5][8..-2]
      data, resp, cookies, forward = post(form_url, postdata, cookies)
      
      if data.index("The e-mail address or password is incorrect")
        raise AuthenticationError, "Username and password do not match"
      elsif data != ""
        raise AuthenticationError, "Required field must not be blank"
      elsif cookies == ""
        raise ConnectionError, PROTOCOL_ERROR
      end
      
      old_url = form_url
      until forward.nil?
        data, resp, cookies, forward, old_url = get(forward, cookies, old_url) + [forward]
      end
      
      if resp.code_type != Net::HTTPOK
        raise ConnectionError, PROTOCOL_ERROR
      end

      forward = "http://www.hotmail.msn.com/cgi-bin/sbox"

      until forward.nil?
        data, resp, cookies, forward, old_url = get(forward, cookies, old_url) + [forward]
      end
      
      if resp.code_type != Net::HTTPOK
        raise ConnectionError, PROTOCOL_ERROR
      elsif old_url.include?('login.live.com')
        data, resp, cookies, forward, old_url = get("http://mail.live.com/mail", cookies)
        data, resp, cookies, forward, old_url = get(forward, cookies)
        old_url = forward
        @use_new_contact_url = true
      end
      
      @domain = URI.parse(old_url).host
      @cookies = cookies
    rescue AuthenticationError => m
      if @attempt == 1
        retry
      else
        raise m
      end
    end
    
  private
    
    def contact_list_url
      "http://www.hotmail.msn.com/cgi-bin/sbox"
      #(@use_new_contact_url ? NEW_CONTACT_LIST_URL : OLD_CONTACT_LIST_URL) % @domain
    end
    
    def follow_email(data, id, contacts_slot)
      compose_url = COMPOSE_URL % @domain
      postdata = "HrsTest=&to=#{id}&mailto=1&ref=addresses"
      postdata += "&curmbox=00000000-0000-0000-0000-000000000001"

      a = data.split(/>\s*<input\s+/i).grep(/\s+name="a"/i)
      return nil if a.empty?

      a = a[0].match(/\s+value="([a-f0-9]+)"/i) or return nil
      postdata += "&a=#{a[1]}"

      data, resp, @cookies, forward = post(compose_url, postdata, @cookies)
      e = data.split(/>\s*<input\s+/i).grep(/\s+name="to"/i)
      return nil if e.empty?

      e = e[0].match(/\s+value="([^"]+)"/i) or return nil
      @contacts[contacts_slot][1] = e[1] if e[1].match(/@/)
    end

    def parse(data)
      if @use_new_contact_url
        data = CSV.parse(data)
        col_names = data.shift
        @contacts = data.map do |person|
          [[person[1], person[2], person[3]].delete_if{|i|i.nil?}.join(" "), person[46]] unless person[46].nil?
        end.compact      
      else
        chunks = data.split('id="hotmail"')
        prev = chunks.delete_at(0)
      
        queue = Queue.new
        threads = []
        @contacts = []
        chunks.each do |chunk|
          name = chunk.split('return false;">')[1].split('</a>')[0] rescue nil
          email = chunk.split('return false;">')[2].split('</a>')[0] rescue nil
          unless email && email != "more"
            prev = chunk
            next
          end
          next_slot = @contacts.size
          @contacts[next_slot] = [name, email]
          if email.match(/\.\.\.$/)
            if m = prev.match(/\s+id="([A-Za-z0-9\-]+)"/)
              queue.push([m[1], next_slot])
              if threads.size < MAX_HTTP_THREADS
                threads.push(Thread.new {
                    while x = queue.pop
                      follow_email(data, *x)
                    end
                })
              end
            end
          end
          prev = chunk
        end
      
        threads.each { queue.push(nil) }
        threads.each { |t| t.join }
        @contacts
      end
    end
    
  end

  TYPES[:hotmail] = Hotmail
end
