class InstructorController < ApplicationController
  include News
  def get_image_for
      #call from class set instructor
      begin
          @inst = Instructor.find(params[:teacher_id])
          render_p 'instructor/set_instructor_image_partial' , {'instructor'=>@inst,'klass_guid'=>params[:class_id]}           
           
      rescue Exception=>e

        render :nothing=>true
      end  
  end

  def image_input      
      flash.keep(:image)
      begin
        @school = School.find(params[:school_id]) 
      rescue
          render :nothing=>true
          return
      end            
      if not params[:rand]
        render_p 'instructor/image_input'
        return
      end            
      begin        
       require 'net/http'
       require 'uri'
       uri = URI.parse(params[:image_url])
       raise(err_msg="Please make sure the image url is from #{@school.name}(#{@school.domain}) domain.") unless @school.is_host_valid?(uri.host)
       message = Net::HTTP.get(uri)        
       image = Image.resize_to message,"150x150"       
       unless image
          raise(err_msg="Invalid image URL. Please enter a valid URL.")
       else 
        flash[:image] = image
       end         
      rescue Exception=>e          
        render :update do |page|
          page.message.show({:message=>(err_msg || "")})          
        end
        return        
      end               
      render :update do |page|                        
          page['teacher_image'].src = url_for(:action=>'flash_image') 
          page.pop.close       
      end   
 
  end

#  def get_remote_image 
#      begin          
#          logger.debug("changin teacher #{@teacher.email_address} profile image")
#          img_blob = Net::HTTP.get(URI(params[:image_url]))
#          @teacher.profile_img = Image.resize_to :small,"JPG",img_blob
#          render :text=>@teacher.profile_img
#          return 
#      rescue Exception=>e
#        logger.debug("Exception::" + e.message)
#      end          
#      render :nothing=>true      
#  end

end
