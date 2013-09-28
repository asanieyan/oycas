#Handles functionality related to posting on walls.
module FacebookWall
  # Post on a wall. You pass it a friend (via the get_friends method) and a
  # message, which is a simple ol' string.
  #   fb.wall_post fb.get_friends.find{|x| x.name=='Mark Zuckerberg'}, 'I <3 Facebook'
  #   fb.wall_post fb.get_friends.random, 'I hate Facebook, and you as well!'
  def wall_post friend, message
    connect_to_friend friend
    id_info = get_ids_from_url "/profile.php?id=#{friend.id}", ['post_form_id','id','user']
    
    req = @http.post2('/ajax/wallpost_ajax.php', "to=#{id_info['id']}&from=#{id_info['user']}&text=#{message}&post_form_id=#{id_info['post_form_id']}", @opts[:headers])
    
    #proper response is a JSON reply starting with wp: ('wallpost' I imagine)
    if req.body.include?('wp:')
      puts "Wrote on #{friend.name}'s wall with: #{message}"
    else
      log req
    end
  end

end
