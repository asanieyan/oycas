class Image 
    require 'RMagick'
    Profile_Sizes = [[:s,70,70],
                    [:m,200,200],
                    [:l,400,400]]
                                 
    Album_Sizes = [[:small,120,70],
             [:medium,300,250],
             [:large,500,500]]
                 
    
    def self.resize data
        ret_val = false 
        (img  = Magick::ImageList.new).from_blob data
        ret_val = []
        Image::Album_Sizes.each do |flag,width,height|
            tmp =  img.change_geometry("#{width}x#{height}") { |cols, rows, tmpimg|
    	        t = tmpimg.resize(cols, rows)
    	        if flag == :small
                  whitebg = Magick::Image.new(width+10,height)
                  t = whitebg.composite(t,Magick::CenterGravity, Magick::OverCompositeOp)
                  t.border!(1,1,"#ffffff") 
                end
                t       	            	          	        
            } 
            tmp.format = "JPG"
            ret_val << [flag,tmp.to_blob]
        end       
        return ret_val    
    end 
    def self.resize_to blob,*sizes,&block                        

        options = sizes.last.is_a?(Hash) ? sizes.pop : {}
        sizes.flatten!    
        format = options[:format] || "JPG"

        images = []
        begin
           sizes.each do |size|           
             (img  = Magick::ImageList.new).from_blob blob
              img.change_geometry(size) { |cols, rows, img|
        	        img = img.resize(cols, rows)
              }
              img.format = format 
              if block_given?
                  img = yield(img,size)
              end
              images << img.to_blob        
           end
           return sizes.size == 1 ? images.shift : images
        rescue Exception=>e
           p e.message
           return sizes.size == 1 ? nil : []
        end                            
    end    
    def self.make_profile_image data,format="JPG"
        ret_val = false 
        begin
          (img  = Magick::ImageList.new).from_blob data
          ret_val = []
          Image::Profile_Sizes.each do |flag,width,height|
              tmp =  img.change_geometry("#{width}x#{height}") { |cols, rows, tmpimg|
      	        tmp = tmpimg.resize(cols, rows)    	              
#    	        if flag == :s
#                  whitebg = Magick::Image.new(width+10,height)
#                  tmp = whitebg.composite(tmp,Magick::CenterGravity, Magick::OverCompositeOp)
#                  tmp.border!(1,1,"#ffffff") 
#                end  
                tmp    	        
              } 
              tmp.format = format
              ret_val << [flag,tmp.to_blob]
          end       
        rescue
        
        end
        return ret_val     
    end
end
