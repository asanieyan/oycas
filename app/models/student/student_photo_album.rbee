class StudentPhotoAlbum < ActiveRecord::Base
  
  Album_Sizes = %w(120x70 128x128 500x500)
  SizeFlags = %w(s m l)
  MAX_UPLOAD_IN_MB = 15
  
  has_many :photos,:class_name=>'AlbumPhoto',:dependent=>:delete_all
  belongs_to :student
  has_guid_field  
  strip_tags_and_truncate %w(location name description)  
  
  def after_create
      FileUtils.mkdir_p File.join(RAILS_ROOT,"public/shared_images/albums/#{self.guid}")
  end
  def before_save
      #check save visibility f
  end
  def validate
     if self.name.length == 0 
        errors.add_to_base "Please enter an album name."        
     end
  end
  def num_photos
      @num_photo ||= AlbumPhoto.count(:all,:conditions=>"student_photo_album_id = #{self.id}")
  end
  def title;self['name'];end;
  def move_all pictures,nalbum
        AlbumPhoto.transaction do           
          pictures.each do |pic|           
              move pic,nalbum
          end  
        end
  end
  def delete_all pictures      
        pictures = [pictures].flatten
        AlbumPhoto.transaction do           
          pictures.each do |pic|           
              delete pic
          end  
        end    
  end
  def get_small_photo photo
      return "/shared_images/albums/#{self.guid}/s#{photo.guid}.jpg"
  end  
  
  def delete picture  
     begin
       dir_name = RAILS_ROOT + "/public/shared_images/albums/#{self.guid}"         
       SizeFlags.each do |size| 
             file_name = "#{size}#{picture.guid}.jpg"
             FileUtils.rm "#{dir_name}/#{file_name}"
             AlbumPhoto.delete picture.id           
       end
     rescue
       
     end
  end
  def move picture,nalbum
      begin       
         new_dir_name = File.join(RAILS_ROOT ,"/public/shared_images/albums/#{nalbum.guid}")
         old_dir_name = File.join(RAILS_ROOT , "/public/shared_images/albums/#{self.guid}")         
         FileUtils.mkdir_p(new_dir_name)     #creat it if is not created 
         SizeFlags.each do |size|
             file_name = "#{size}#{picture.guid}.jpg"
             FileUtils.mv "#{old_dir_name}/#{file_name}","#{new_dir_name}/#{file_name}" 
             picture.student_photo_album_id = nalbum.id
             picture.save
         end
       rescue Exception=>e
#          p e.message
       end
  end
  def has_cover?
      return File.exists?(File.join(RAILS_ROOT, "/public",cover_file))
  end
  def cover_file
       "/shared_images/albums/#{self.guid}/m#{self.album_cover || ''}.jpg"
  end
  def get_medium_photo photo
      return "/shared_images/albums/#{self.guid}/m#{photo.guid}.jpg"
  end
  def get_large_photo photo
      return "/shared_images/albums/#{self.guid}/l#{photo.guid}.jpg"  
  end
  def cover        
       if has_cover?
          return cover_file
       else
          return "/images/framebig.gif"
       end 
  end
  def set_cover photo_guid
       begin
         #pic = AlbumPhoto.find_by_guid_and_student_photo_album_id(photo_guid,self.id)  
         self.album_cover = photo_guid.to_i
         self.save
       rescue Exception=>e
            p e.message
       end
  end
  alias cover= set_cover
  def num_images
        return @num_images ||= AlbumPhoto.count(:conditions=>"student_photo_album_id = #{self.id}").to_s
  end
  def before_destroy      
      FileUtils.remove_dir(RAILS_ROOT + "/public/shared_images/albums/#{self.guid}") rescue return

  end
  def save_photos uploaded_tmp_files                                              
       dir_name = RAILS_ROOT + "/public/shared_images/albums/#{self.guid}"
       FileUtils.mkdir_p(dir_name)         
       album_cover = nil       
       images = DocumentFile.truncate([uploaded_tmp_files].flatten,
          :filter_in=>DocumentFile::SuppoertedImages)
       
       images.each do |tmp_file|                                   
             begin 
                 File.open(tmp_file.path,"rb") do |inf|
                   AlbumPhoto.transaction do                 
                      
                      photo = AlbumPhoto.create 'student_photo_album_id'=> self.id, 
                                                'student_id'=>self.student.id                    
                      Image.resize_to(inf.read,Album_Sizes).each_with_index { |image,i|                        
                              
                              @photo_path = File.join(dir_name,"#{SizeFlags[i]}#{photo.guid}.jpg")                               
                              File.open(@photo_path,"wb") {|outf| outf.write image}
                      }                    
                  end                                                           
              end              
            rescue Exception=>e
                    p e.message
  #                  logger.debug e.message
                FileUtils.rm(@photo_path) rescue nil
            end          
       end        
    end  

end
