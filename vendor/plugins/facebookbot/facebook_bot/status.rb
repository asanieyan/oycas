#Handles updating statuses on Facebook. Pretty straight forward.
module FacebookStatus
  #Updates your status with the provided string. Will blow up if you give it
  #an array, or anything insane like that.
  #   fb.set_status 'getting caught in the rain'
  def set_status status
    login
    post_form_id = get_ids_from_url('/home.php', ['post_form_id'])['post_form_id']
    req = @http.post2('/updatestatus.php', "status=#{status}&post_form_id=#{post_form_id}", @opts[:headers])
    if req.body.include?(status)
      puts "Set status to: #{status}"
    else
      log req
    end
  end
  
end
