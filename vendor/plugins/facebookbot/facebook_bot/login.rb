#Handles all login-related functionality to Facebook. This is a staple. Can't
#do much on facebook without logging in!
module FacebookLogin
  #Login to facebook. Doesn't take any arguments and is generally not supposed
  #to be called directly. When you create a new Facebook object, it will
  #automatically try_try_again to login. It reads the username and password
  #straight from @opts. Probably is pretty insecure, since it uses SSL to send your
  #request. Will update session cookie upon successful login, to be used throughout
  #the rest of the functions. You'll want to call this function a lot, it will only try
  #to login if 
  #    fb.login
  def login
    connect # to reset any weird-o connections we might have done in the past.
    if @opts[:cookie]
      @opts[:headers]['Cookie'] = @opts[:cookie]
      req = @http.get2('/', @opts[:headers])
      if req.code.to_i == 302
        puts "Successfully used cookie to login!"
        @default_host = URI.parse(req.response['location']).host
      else
        puts "Failed to login with cookie!"
        log req
      end
    else
      #only login if we haven't in the last minute
      if @last_login.nil? || @last_login+60 < Time.now.to_i
        #logout
        connect 'www.facebook.com' #reconnect to basic address.
        @opts[:headers]['Cookie'] = 'test_cookie=1' #clear cookies to logout
        # get the login challenge
        doc = hpricot_get_url '/'
        challenge = doc.at("input[@name='challenge']").attributes['value']

        #login !
        loginhttp = Net::HTTP.new('login.facebook.com', 443)
        loginhttp.use_ssl = true
        loginhttp.verify_mode = OpenSSL::SSL::VERIFY_NONE # disables pesky warnings

        login = loginhttp.post2('/login.php', "md5pass=&noerror=0&email=#{@opts[:email]}&pass=#{@opts[:password]}&doquicklogin=Login&challenge=#{challenge}", @opts[:headers])

        #302 redirect == successful login!
        if login.code.to_i == 302
          @default_host = URI.parse(login.response['location']).host
          connect @default_host
          puts "Successfully logged in!"
          @last_login = Time.now.to_i
          update_session login.response['set-cookie']
        else
          puts "Failed to login!"
          log login
        end
      end
    end
  end
  
  #Update the login session with new cookies.
  def update_session cookie
    if !cookie.nil?
      #sanatize cookie
      cookie.gsub!(/path=\/; /,'')
      cookie.gsub!(/httponly, /,'')
      cookie.gsub!(/domain=\.facebook.com; /,'')
      cookie.gsub!(/expires=[^;]+;/,'')
      cookie.gsub!(/path=\//,'')
      cookie.gsub!(/\s+/,' ')
      @opts[:headers]['Cookie'] = cookie
    end
  end
  
  #Tests whether we have logged in successfully or not via cookies. And love.
  #   if !fb.logged_in?
  #     raise 'you dunce!'
  #   end
  def logged_in?
    @opts[:headers]['Cookie'] =~ /login/i
  end
end