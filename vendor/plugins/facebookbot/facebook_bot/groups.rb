#Does that whole group finding and joining thing. You know.
#You can use these two functions together to join groups. Like so:
#  fb.join_group(fb.find_group('puppy'))
module FacebookGroups
  #Finds a random group based on a search term. If there is
  #only one result, great, it grabs that group id.
  #Otherwise, it will choose a random group out of the
  #results and return that group id. NOTE: This searches
  #global groups only, currently. So, like, not within your network.
  #  fb.find_group 'sheep' # will return something like '200040300'
  def find_group term
    login
    doc = hpricot_get_url("/s.php?q=#{term}&n=0&k=20010&s=0")
    # figure out the number of results
    begin
      num_results = doc.at("//li[@class='current']//a").inner_html
    rescue
      return -1 # we failed to find any matching groups
    end
    if num_results =~ /500\+/
      max = 500
    else
      max = num_results.split(' ')[0].to_i
    end
    
    #if there's more than one result, we'll want to find one random group
    #out of the set
    #TODO: what about 2-10 results?
    if max > 1
      #grab a random page of results from 0 to max
      random_page = rand(max)
      #re-search!
      doc = hpricot_get_url("/s.php?q=#{term}&n=0&k=20010&s=#{random_page}")
    end
    
    #pick a random group that we can join (ones that we can join have onclicks)
    group = doc.search("//ul[@class='actionspro']/li/a[@onclick]").random
    
    #figure out its group id
    group.attributes['onclick'] =~ /var dialog_(\d+) /i
    $1
  end
  
  #Joins a group given a group_id.
  #  fb.join_group '3400030020'
  #  fb.join_group fb.find_group('cats')
  def join_group group_id
    login
    
    #find a post_form_id, any old one will do.
    post_form_id = get_ids_from_url("/home.php", ['post_form_id'])['post_form_id']

    req = @http.post2('/ajax/group_actions_ajax.php',"gid=#{group_id}&join=1&post_form_id=#{post_form_id}",@opts[:headers])
    
    #we get a 0 back on success, for whatever reason.
    if req.body.include?('0')
      puts "Successfully joined group ##{group_id}."
    else
      puts "Failed to join group ##{group_id}!"
      log req
    end
  end
  
end
