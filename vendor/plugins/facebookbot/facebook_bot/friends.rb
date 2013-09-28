#Who doesnt love friends? We all love friends. I hope.
module FacebookFriends
  def get_friends_in network_ids
    network_ids = [network_ids] unless network_ids.is_a? Array
    login
    friends = []
    network_ids.each do |id|
      doc = hpricot_get_url "/friends.php?nk=#{id}"   
      (doc/"td.name/a").each do |friend_row|
        friends << parse_friend_row(friend_row)
      end
    end
    friends    
  end
  #Gets all of your friends. Returns a Array full of FaceBookFriends. Seeing is believing:
  #   friends = fb.get_friends
  #Use your imagination.  
  def get_friends
    login
    friends = []
    doc = hpricot_get_url '/friends.php'
    
    # loop through the friends and collect'em all! pokemon style.
    (doc/"td.name/a").each do |friend_row|
      friends << parse_friend_row(friend_row)
    end
    friends
  end
  
  #Find a random friend in your networks and returns that FacebookFriend.
  #  fb.find_random_friend
  def find_random_friend
    login
    doc = hpricot_get_url '/b.php?k=10010'
    friend_row = (doc/"div.result//dd.result_name/a").random
    parse_friend_row friend_row
  end
  
  
  #Finds a friend given a search term (like, uh, their name.) and returns
  #that FacebookFriend
  #If more than one result is found, it will choose one result at random. 
  #If you have someone specific in mind, just add_friend directly.
  def find_friend term
    login
    
  end
  
  #Sends a friend request to the given FacebookFriend.
  #Usually used in conjunction with find_friend or find_random_friend,
  #but you can call it all on your own if you want. You can specify a message
  #to send to the friend as well.
  #  fb.add_friend FacebookFriend.new('32423423','Mark Zuckerberg','http://blah.facebook.com/profile.php?id=23423423'), 'i like you'
  #  fb.add_friend fb.find_random_friend
  def add_friend friend, message=''
    login
    url = "/addfriend.php?id=#{friend.id}"
    post_form_id = get_ids_from_url(url, ['post_form_id'])['post_form_id']
    
    req = @http.post2(url,"post_form_id=#{post_form_id}&message=#{message}&confirmed=1",@opts[:headers])
    
    if req.body.include?('A friend request will now be sent')
      puts "Successfully sent a friend request to #{friend.name}.";
    elsif req.body.include?('There is already a friend request')
      puts "There is already a friend request for #{friend.name}!"
    else
      puts "Failed to add #{friend.name} as my friend!"
      log req
    end
  end
  
  #Connect to the proper host like emerson.facebook.com, so we can view their profile
  #and do things like post on their wall.
  def connect_to_friend friend
    login
    connect friend.network_domain
  end
  
  private
  #Parses a friend_row which is a link found on the friend search pages. It is used as a helper function. You'll
  #probably not call this by itself.
  def parse_friend_row friend_row
    url = friend_row.attributes['href']
    name = friend_row.inner_html
    if url =~ /id=(\d+)/
      id = $1
    else
      id = 0
    end
    FacebookFriend.new(id,name,URI.parse(url).host)
  end
end
