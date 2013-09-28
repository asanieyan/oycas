module PhotoAlbum
    def self.included(base)
          base.class_eval do
              def self.add_album_methods owner=""                  
                  @photo_owner = owner 
                  
              end           
              before_filter :only=>%w(photo view_album) do |c|                          
                  c.send :set_photo_owner                    
              end              
              before_filter :only=>%w(view_album) do |contr| 
                          contr.send :set_album_instance
              end              
              private
                  def set_photo_owner 
                      instance_variable_set("@photo_owner",                       
                          eval(self.class.instance_variable_get("@photo_owner"),binding))                     
                  end
                  def set_album_instance (guid=params[:a],var = "@album")                      
                      begin                    
                        set_photo_owner
#                        @photo_owner ||= @me                                                             
                        instance_variable_set(var,                          
                          StudentPhotoAlbum.find(:first,:conditions=>["student_id = #{@photo_owner.id} AND guid = ?",guid.to_i]))                           
                          return true if instance_variable_get(var)
                      rescue Exception=>e 
                        raise e 
                      
                      end
                      if not request.xml_http_request? 
                          redirect_to :action=>'photo' 
                      else
                          render :update do |page|
                            page.redirect_to :action=>'photo'
                          end
                      end   
                      return false         
                  end                            
              public              
             def view_album                
                #am I allowed to see this album
                         
                relation_level = @my.relation_with @photo_owner               
                if @album.visibility < relation_level 
                  redirect_to :controller=>'my'
                  return
                end
                if params[:p]
                  @album.photos.each_with_index do |p,i|
                      if p.guid == params[:p].to_i
                          @photo = p
                          @next_photo = i+1 >= @album.photos.size ? @album.photos.first: @album.photos[i+1]
                          @prev_photo = i-1 < 0 ? @album.photos.last : @album.photos[i-1]
                          break;
                      end
                  end

                  if @photo 
                    render :template=>'albums/view_album'
                    return
                  end
                end
                @paginator,@photos = paginate :album_photo,:per_page=>15,
                                      :conditions=>"student_photo_album_id = #{@album.id}",:order=>"id ASC"
                                        
                render :template=>'albums/view_album'

             end              
             def photo
                #show the albums that I can see 
                relation_level = @my.relation_with @photo_owner
                @paginator,@albums = paginate :student_photo_album,:per_page=>10,
                                               :conditions=>"student_id = #{@photo_owner.id} AND visibility >= #{relation_level}",
                                               :order=>"created_on DESC"
                render :template=>'albums/photo' 
             end   
          end                           
    end

end