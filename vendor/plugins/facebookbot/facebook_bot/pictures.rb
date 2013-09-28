#Handles all Picture related functionality. Mainly, uploading pictures to
#Facebook and tagging them all nice.
module FacebookPictures
  #Changes the profile picture given a picture filename. Can only (currently)
  #take JPEGs. It will blow up on anything else.
  #   fb.change_profile_picture 'cute.jpg'
  def change_profile_picture picture
    login
    id_info = get_ids_from_url '/editprofile.php?picture', ['id','code']
    params = id_info.merge({'type' => 'profile',
                            'return' =>'editprofile.php?picture',
                            'agree' => '1',
                            'uploadbutton' => 'Upload Picture'})
    upload_file_to_url picture,'/pic_upload.php', params
  end
  
  #Shortcut function to tag your profile picture with subject (FacebookFriend or 'self') and Position [x%,y%].
  #subject can be 'self' if you're taggging a picture of yourself.
  #  fb.tag_profile_picture 'self', [49.232,23.230]
  #  fb.tag_profile_picture '34534522', [49.232,23.230]
  #  fb.tag_profile_picture fb.get_friends.find{|x| x.name == 'Mark Zuckerberg'}, [49.232,23.230]
  def tag_profile_picture friend, position
    login
    tag_picture get_pictures('http://www.facebook.com/album.php?profile')[0], friend, position
  end
  
  #Tag a picture of picture_id (found via the get_pictures method, probably) with
  #a subject (FacebookFriend instance of person tagging, or 'self' if we're tagging ourself.) and at a
  #position [x%,y%] Array, usually found via random.position.
  #  fb.tag_picture get_pictures('http://www.facebook.com/album.php?profile')[0], 'self', [5,5]
  #  fb.tag_picture '40009493', 'self', [40.232,23.3434]
  #  fb.tag_picture '43253433', '3453453434', [22.232,54.3434]
  #  fb.tag_picture '2334534534', fb.get_friends.find{|x| x.name == 'Mark Zuckerberg'}, [54.1,10.2]
  def tag_picture picture_id, friend, position
    login
    img_str, pid, id = picture_id.split('_')
    
    # if we're tagging self, create a dummy friend to use of myself.
    if friend == 'self'
      friend = FacebookFriend.new(id,'myself','')
    end
    
    subject = friend.id
    
    post_form_id = get_ids_from_url("/photo.php?pid=#{pid}&id=#{id}", ['post_form_id'])['post_form_id']
    
    req = @http.post2('/ajax/photo_tagging_ajax.php',"pid=#{pid}&id=#{id}&subject=#{subject}&name=disregarded&email=&action=add&x=#{position[0]}&y=#{position[1]}&post_form_id=#{post_form_id}",@opts[:headers])
    
    if req.code.to_i == 200
      puts "Successfully tagged a photo of #{friend.name} at #{position[0]},#{position[1]}."
    else
      puts "Failed to tag a photo of #{friend.name}!"
      log req
    end
  end
  
  #Gets a list of all pictures in an album, given a album URL. Returns a list of image
  #IDs. An example is worth a thousand words:
  #   pictures = fb.get_pictures 'http://www.facebook.com/album.php?profile'
  #Pictures Array is now something like:
  #   ['img_56425733_1813949','img_35978903_1813949',...]
  def get_pictures url
    login
    connect URI.parse(url).host
    doc = hpricot_get_url url
    
    pictures = []
    doc.search("//div[@id='album']//img") do |img|
      pictures << img.attributes['id']
    end
    pictures
  end

private
  #thanks http://www.realityforge.org/articles/2006/03/02/upload-a-file-via-post-with-net-http
  def upload_file_to_url file, url, other_params
    connect 'upload.facebook.com'
    if !FileTest.exist?(file)
      puts "No such file to upload: #{file}" and return
    end
    data = File.open(file,'rb').read
    params = [file_to_multipart('pic','test.jpg','image/jpeg',data)]
    other_params.each do |key, val|
        params << text_to_multipart(key,val)
    end
    
    boundary = '349832898984244898448024464570528145'
    query = params.collect {|p| '--' + boundary + "\r\n" + p}.join('') + "--" + boundary + "--\r\n"
    headers = @opts[:headers].reject{|key,val| key == 'Content-Type'}
    headers=headers.merge({"Content-type" => "multipart/form-data; boundary=" + boundary})
    
    req = @http.post2(url,query,headers)
    if req.code.to_i == 302 && req.response['location'].include?('success=1')
      puts "Successfuly updated profile picture to #{file}!"
    else
      puts "Failed to update profile picture to #{file}!"
      log req
    end
  end
  
  def text_to_multipart(key,value)
    "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"\r\n" + 
    "\r\n" + "#{value}\r\n"
  end

  def file_to_multipart(key,filename,mime_type,content)
    "Content-Disposition: form-data; name=\"#{CGI::escape(key)}\"; filename=\"#{filename}\"\r\n" +
    "Content-Transfer-Encoding: binary\r\n" +
    "Content-Type: #{mime_type}\r\n" + 
    "\r\n" + 
    "#{content}\r\n"
  end
    
end
