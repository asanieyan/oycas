#Wanna poke somebody? Of course you do. This old adage. This old house.
module FacebookPoke
  #Poke someone, given a FacebookFriend and optionally a boolean answer to "Is this a pokeback?"
  #  fb.poke fb.get_friends.random
  #  fb.poke fb.get_friends.find{|x| x.name == 'Mark Zuckerberg'}, true
  def poke friend, pokeback=false
    connect_to_friend friend
    id_info = get_ids_from_url "/profile.php?id=#{friend.id}", ['post_form_id','id']
    pokeback = pokeback == true ? 1 : 0
    
    req = @http.post2('/ajax/poke.php', "uid=#{id_info['id']}&pokeback=#{pokeback}&post_form_id=#{id_info['post_form_id']}", @opts[:headers])
    if req.body.include?('You have poked')
      puts "Poked #{friend.name}."
    elsif req.body.include?('has not received')
      puts "Already have a pending poke for #{friend.name}."
    else
      log req
    end
  end
  
end
