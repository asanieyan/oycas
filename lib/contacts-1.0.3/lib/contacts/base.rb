require "cgi"
require "net/http"
require "net/https"
require "uri"
require "zlib"
require "stringio"
require "thread"

class Contacts
  TYPES = {}
  VERSION = "1.0.3"
  
  class Base
    def initialize(login, password)
      @login    = login
      @password = password
      @connections = {}
      connect
    end
    
    def connect
      raise AuthenticationError, "Login and password must not be nil, login: #{@login.inspect}, password: #{@password.inspect}" if @login.nil? || @password.nil?
      real_connect
    end
    
    def connected?
      @cookies && !@cookies.empty?
    end

    def contacts
      return @contacts if @contacts
      if connected?
        url = URI.parse(contact_list_url)
        http = open_http(url)
        resp, data = http.get("#{url.path}?#{url.query}",
          "Cookie" => @cookies #"__utma=173272373.1633649994.1181924036.1228074361.1228083444.16; __utmx=173272373.00000361972142287121:1:0-0; __utmz=173272373.1228074361.15.1.utmccn=(direct)|utmcsr=(direct)|utmcmd=(none); __utmc=173272373; gmailchat=asanieyan@gmail.com/211854; GX=DQAAAHkAAACsMKszDxN6V9LPbb0HVsYCjBhG6KpeFy4wkmJU1R8I3lA9CN7BD7arCbvM9w4elSXfbSCwbwlk5qz43g9R-uHvROnSOFGTqdBTWjGeIyUkzufettgiRhmwohJ8dquiEAnP0SwYQ21wpqmTFZGX-8nwxpdsrDjSHXdC7bBKrMQJvg; S=gmail=D84cKujJBI5NIki-C4GY8A:gmail_yj=7C09GuPAapsOUl_gyRPdXA:gmproxy=kUMEi-phwz8:gmproxy_yj=YILtt2YkZsc:gmproxy_yj_sub=2uTGtBQK3do; GMAIL_AT=8bb6e3de3b74dabd-11374324073; GMAIL_LOGIN=1228083443302/1228083443302/1228083453496/1228083464252/1228083464723/1228083465794/1228083466505/false/false; GMAIL_ZY=f; PREF=ID=99ac317ec8f3a26c:TM=1181915847:LM=1181924049:GM=1:S=gib0faBYG3jG0aOu; TZ=480; GMAIL_RTT=70; GMAIL_LOGIN=T1228083443302/1228083443302/1228083453496; SID=DQAAAHcAAABn0LCZlwKd6YSvTvl_8WNvQF67XXp1RtXS7Kxhj616L72K-sgsdzJ0iUqLFZqITUGWBcfyGty6woe5rOIGnSqg_YGbqqGGUW0kVPM8i7yHSNi8bd2fWeBE_PURaNuRYf1YvbVkc5msfR5K-x7SRB7OIIWfxPpEw70s2c54UkLg2A; GMAIL_HELP=hosted:0; S=gmail=D84cKujJBI5NIki-C4GY8A:gmail_yj=7C09GuPAapsOUl_gyRPdXA:gmproxy=kUMEi-phwz8:gmproxy_yj=YILtt2YkZsc:gmproxy_yj_sub=2uTGtBQK3do; N_T=sess=8005eddd208f800&v=2&c=a6b5708d&s=46854bda&t=A:1:24911&sessref=; GmailUserLocale=en"
        )
        if resp.code_type != Net::HTTPOK
          raise ConnectionError, self.class.const_get(:PROTOCOL_ERROR)
        end

        parse data
      end
    end
    
    def login
      @attempt ||= 0
      @attempt += 1
            
      if @attempt == 1
        @login
      else
        if @login.include?("@#{domain}")
          @login.sub("@#{domain}","")
        else
          "#{@login}@#{domain}"
        end
      end
    end
    
    def password
      @password
    end
    
  private
  
    def domain
      @d ||= URI.parse(self.class.const_get(:URL)).host.sub(/^www\./,'')
    end

    def contact_list_url
      self.class.const_get(:CONTACT_LIST_URL)
    end

    def open_http(url)
      c = @connections[Thread.current.object_id] ||= {}
      http = c["#{url.host}:#{url.port}"]
      unless http
        http = Net::HTTP.new(url.host, url.port)
        if url.port == 443
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        c["#{url.host}:#{url.port}"] = http
      end
      http.start unless http.started?
      http
    end
    
    def parse_cookies(data, existing="")
      return existing if data.nil?

      cookies = existing.split(";").map{|i|i.split("=", 2).map{|j|j.strip}}.inject({}){|h,i|h[i[0]]=i[1];h}
      
      data.gsub!(/ ?[\w]+=EXPIRED;/,'')
      data.gsub!(/ ?expires=(.*?, .*?)[;,$]/i, ';')
      data.gsub!(/ ?(domain|path)=[\S]*?[;,$]/i,';')
      data.gsub!(/[,;]?\s*(secure|httponly)/i,'')
      data.gsub!(/(;\s*){2,}/,', ')
      data.gsub!(/(,\s*){2,}/,', ')
      data.sub!(/^,\s*/,'')
      data.sub!(/\s*,$/,'')
      
      data.split(", ").map{|t|t.to_s.split(";").first}.each do |data|
        k, v = data.split("=", 2).map{|j|j.strip}
        if cookies[k] && v.empty?
          cookies.delete(k)
        elsif v && !v.empty?
          cookies[k] = v
        end
      end
      
      cookies.map{|k,v| "#{k}=#{v}"}.join("; ")
    end
    
    def remove_cookie(cookie, cookies)
      parse_cookies("#{cookie}=", cookies)
    end
    
    def post(url, postdata, cookies="", referer="")
      url = URI.parse(url)
      http = open_http(url)
      resp, data = http.post(url.path, postdata,
        "User-Agent" => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1) Gecko/20061010 Firefox/2.0",
        "Accept-Encoding" => "gzip",
        "Cookie" => cookies,
        "Referer" => referer,
        "Content-Type" => 'application/x-www-form-urlencoded'
      )
      data = uncompress(resp, data)
      cookies = parse_cookies(resp.response['set-cookie'], cookies)
      forward = resp.response['Location']
      return data, resp, cookies, forward
    end
    
    def get(url, cookies="", referer="")
      url = URI.parse(url)
      http = open_http(url)
      resp, data = http.get("#{url.path}?#{url.query}",
        "User-Agent" => "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; en-US; rv:1.8.1) Gecko/20061010 Firefox/2.0",
        "Accept-Encoding" => "gzip",
        "Cookie" => cookies,
        "Referer" => referer
      )
      data = uncompress(resp, data)
      cookies = parse_cookies(resp.response['set-cookie'], cookies)
      forward = resp.response['Location']
      return data, resp, cookies, forward
    end
    
    def uncompress(resp, data)
      case resp.response['content-encoding']
      when 'gzip':
        gz = Zlib::GzipReader.new(StringIO.new(data))
        data = gz.read
        gz.close
        resp.response['content-encoding'] = nil
      # FIXME: Not sure what Hotmail was feeding me with their 'deflate',
      #        but the headers definitely were not right
      when 'deflate':
        data = Zlib::Inflate.inflate(data)
        resp.response['content-encoding'] = nil
      end

      data
    end
  end
  
  class ContactsError < StandardError
  end
  
  class AuthenticationError < ContactsError
  end

  class ConnectionError < ContactsError
  end
  
  class TypeNotFound < ContactsError
  end
  
  def self.new(type, login, password)
    if TYPES.include?(type.to_s.intern)
      TYPES[type.to_s.intern].new(login, password)
    else
      raise TypeNotFound, "#{type.inspect} is not a valid type, please choose one of the following: #{TYPES.keys.inspect}"
    end
  end
  
  def self.guess(login, password)
    TYPES.inject([]) do |a, t|
      begin
        a + t[1].new(login, password).contacts
      rescue AuthenticationError
        a
      end
    end.uniq
  end
end
