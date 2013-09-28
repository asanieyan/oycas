#Handles functionality related to posting on messages.
#this file was missing so i had to add this method myself
module FacebookMessages
   def send_message friends, subject, message
     #convert to array if they only gave us one friend.

     friends = [friends] if friends.class != Array
     #get the post_form_id

     post_form_id = get_ids_from_url('/inbox/?compose', ['post_form_id'])['post_form_id']
     
     #rand_id = Math.floor((Math.random() * 100000000)); not sure what this is.

     rand_id = rand(100000000)
     
     #gather up the friends and parse them into a ids[] querystring

     #i.e. ids[]=235423&ids[]=45645&... etc

     id_querystring = []
     friends.each do |friend|
       id_querystring << "ids[]=#{friend.id}"
     end
     id_querystring = id_querystring.join('&')
     
#     req = do_http { @http.post2('/inbox/', "#{id_querystring}&subject=#{subject}&message=#{message}&rand_id=#{rand_id}&post_form_id=#{post_form_id}", @opts[:headers]) }
     req = @http.post2('/inbox/', "#{id_querystring}&subject=#{subject}&message=#{message}&rand_id=#{rand_id}&post_form_id=#{post_form_id}", @opts[:headers])
     if req.code.to_i == 302 && req.response['location'].include?('readmessage.php')
       puts "Successfully sent a message to #{friends.length} friends!"
     else
       puts "Failed to send a message."
       log req
     end
   end

end
