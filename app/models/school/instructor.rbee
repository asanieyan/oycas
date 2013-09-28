class Instructor < ActiveRecord::Base
  ProfileDir = '/shared_images/teacher_profiles/'
  belongs_to :school
  
  def validate
      self.class.send :include,ActionView::Helpers::TextHelper
      self.first_name = strip_tags(first_name).capitalize rescue ""
      self.last_name = strip_tags(last_name).capitalize rescue ""
      self.email_address =strip_tags(email_address).downcase 
      return true
  end
  def name2
      names = []
      names << first_name if (first_name || "").size > 0     
      names << last_name if (last_name || "").size > 0
      names = names.reverse.join(", ")
      names = " ( #{names} )" if names.size > 0
      return self.email + names
  end
  def name1
      names = []
      names << first_name if (first_name || "").size > 0     
      names << last_name if (last_name || "").size > 0
      names = names.reverse.join(", ")
      if names.size == 0
        return self.email
      else
        return names
      end
  end
  def has_profile_image?
    File.exists?(RAILS_ROOT+"/public/"+(img_file=Instructor::ProfileDir + self.id.to_s + ".jpg"))
  end
  def save_info first_name,last_name
#      self.email_address = email
      self.first_name = first_name
      self.last_name = last_name
      self.save
  end
  def email;email_address;end;
  def set_profile_image_from_net http_address
       require 'net/http'
       require 'uri'
       uri = URI.parse(URI.escape(http_address)) rescue (return false)
       message = Net::HTTP.get(uri)        
       image = Image.resize_to message,"150x150" 
       self.profile_img= image if image             
  end
  def profile_img=img_data
       profile_dir = RAILS_ROOT + "/public/" + Instructor::ProfileDir
       FileUtils.mkdir_p(profile_dir)       
       f  = File.open( File.join(profile_dir,self.id.to_s + ".jpg"),"wb")
       f.write img_data
       f.close
  end
  def profile_img      
      if File.exists?(RAILS_ROOT+"/public/"+(img_file=Instructor::ProfileDir + self.id.to_s + ".jpg"))
          return img_file
      else
          return '/images/manonymous.gif'
       end
          
  end
end
