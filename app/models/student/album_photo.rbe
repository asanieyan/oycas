class AlbumPhoto < ActiveRecord::Base
  belongs_to  :album,:class_name=>'StudentPhotoAlbum',:foreign_key=>'student_photo_album_id'
  belongs_to  :student
  #there both field names student_id and student_photo_album_id in the album_photos table 
  has_guid_field 
  
  strip_tags_and_truncate 'caption'  
  before_save do |obj|
          obj.caption = nil if obj.caption !~ /\S/
  end
end
