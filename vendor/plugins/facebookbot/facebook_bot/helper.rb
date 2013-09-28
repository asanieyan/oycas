#These are some helper methods to get you along in life. Use wisely, young one.
module FacebookHelper
  #Will get a URL and parse it with the (lovely) hpricot library. Returns
  #The parsed Hpricot object, to which you can do what you please.
  #    doc = fb.hpricot_get_url '/home.php'
  def hpricot_get_url url
    req = try_try_again do
      @http.get2(url, @opts[:headers])
    end
    
    if req.code.to_i != 200
      log(req) and return
    end
    
    Hpricot(req.body)
  end
  
  #Gets the contents of any IDs it finds on a given page. Takes an array of IDs.
  #Returns a hash of ID information, keys being the IDs provided.
  #Useful for getting basic information from a page, such as the verification
  #post_form_id's, and any other information you so desire.
  #Will try to extract this information from the ID, or give up: (in order)
  #ID value, ID src, ID innerHTML.
  #    id_info = fb.get_ids_from_url '/home.php', ['post_form_id']
  def get_ids_from_url url, ids
    elements = {}
    # go to the url
    doc = hpricot_get_url url
    
    ids.each do |id|
      tries = 0
      while elements[id].nil? 
        ele = doc.at("##{id}")
        if ele.nil?
          puts "cannot get id #{id}"
          elements[id] = 'unknown'
        elsif ele.attributes['value']
          elements[id] = ele.attributes['value']
        elsif ele.attributes['src']
          elements[id] = ele.attributes['src']
        elsif ele.inner_html
          elements[id] = ele.inner_html
        end
      end
    end
    elements
  end
  
  #If at first you don't succeed... try try again. This function takes a block
  #and will try(and try and try and try) that block until it finally doesn't
  #raise an error. This is useful if you are getting timeouts or other such
  #errors while grabbing some information. I use it liberally just in case I get
  #disconnected temporarily (which is often).
  def try_try_again
    begin
      yield
    rescue Timeout::Error => err
      puts "Timeout Error: #{err}! Retrying.."
      retry
    rescue Exception => exception
      puts "Exception: #{exception.message}! Retrying.."
      retry
    end
  end
  
  #Logs a bad Net::HTTP request. Appends to a file(log.txt) and prints to the
  #console.
  def log req
    msg = "ERROR: #{req.code}: #{req.message}\nbody: #{req.body}\nheaders: #{req.response.to_hash.inspect}"
    File.open('log.txt','a') do |f|
      f.puts msg
    end
    puts msg
  end
  
  # Connect somewhere to Facebook!
  #--
  # TODO: refactor. can't i modify my active @http connection
  # instead of creating a new one? it's just a subdomain.
  #++
  #   fb.connect 'emerson.facebook.com'
  def connect host=nil
    # should we try to connect to our default_host?
    # changes on a network to network basis.
    # www if you're on a regional network.
    if host.nil? && @default_host
      host = @default_host
    elsif host.nil?
      host = 'www.facebook.com'
    end
    if @http.nil? || @http.address != host
      @http = Net::HTTP.new(host)
      puts "Connected to #{host}."
    end
  end

end