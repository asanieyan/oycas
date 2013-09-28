class ClassifiedPost < ActiveRecord::Base
    has_one :attribute_list ,:class_name=>'ItemAttributeValue'                
    has_many :replies,:class_name=>'ClassifiedPostReply',:foreign_key=>'post_id',:order=>"created_on DESC",:dependent=>:delete_all
    belongs_to :poster,:class_name=>'Student',:foreign_key=>'poster_id'
    belongs_to :category, :class_name=>'ClassifiedCategory'
    belongs_to :network
    has_many :images, :class_name=>'PostImage',:dependent => :destroy
        
    
    strip_tags_and_truncate 'title'
    
    sanitize_html 'description'
    
    require 'classified_category.rb'   
    def owner;poster;end;
    def get_attribute_value attrb       
        #this is called from _post.rhtml
        map_index = AttributeCategoryMap.find_map_index(classified_category_id,attrb.id).attribute_index           
        attribute_list["attrb_" + map_index.to_s + "_value"] || ""
#        return attribute_list["attrb_" + map_index.to_s + "_value"] || ""
    end

    def item_attributes
        item_attributes = []
        ItemAttributeValue.column_names.each do |column|
           if column =~ /attrb_\d_value/ and (attr_value = self.attribute_list[column] || "").size > 0                                
                item_attributes << [get_attribute_name(column),attr_value]
           end        
        end

        item_attributes
    end
    def get_generic_attribute_for column        

        #column should be in the attrb_\d_value formate 
        attrb_index = column.gsub(/attrb_(\d)_value/,'\1').to_i
        raise Exception, "Excpected an attribute position greater than 0" if attrb_index == 0 
        #find the generic attribute that is mapped to this post category and with position attrib_index
        attrb_map = AttributeCategoryMap.find(:first, :conditions=>"classified_category_id = #{category.id} AND attribute_index = #{attrb_index}")        
        return attrb_map.generic_attribute
        
    end
    alias get_attribute_name get_generic_attribute_for
    def add_values validated_values        
      #these values must have been validated first 
      #also all the attributes must have had their position index set first 
      #if not it will throw exception 
     item_values_table = {}
         validated_values.each do |attribute,attribute_value|
                raise Exception, "this attribute field is already taken" if item_values_table["attrb_#{attribute.category_position}_value"]         
                item_values_table["attrb_#{attribute.category_position}_value"] = attribute_value
                
         end
      create_hash = {:classified_post_id=>self.id, :classified_category_id=>self.classified_category_id}
      create_hash.merge!(item_values_table)
      item_values = self.attribute_list
      if item_values
        item_values.attributes= create_hash
        item_values.save
      else
        ItemAttributeValue.create create_hash
      end
       
    end
    def listable_attributes
          @listable_attributes ||= ItemAttributeValue.find_by_sql(
          "SELECT m.input_value " + 
          "FROM item_attribute_values as m,generic_attributes as ga " + 
          "WHERE m.classified_post_id = #{id} AND ga.id = m.generic_attribute_id AND ga.display_position > 0 ORDER BY ga.display_position ASC"
          )
    end
    def save_image data
        if self.images.size <= 10
          begin
            PostImage.transaction do 
              image = PostImage.create(:classified_post_id=>self.id)
              image.src= data
            end  
          rescue Exception=>e
           
          end           
        end
    end
    def listing_image
       @listings_image ||= PostImage.find(:first,:conditions=>"classified_post_id = #{self.id}") 
    end
    alias has_listing_image? listing_image
    def delete_image id
      image = PostImage.find(id)
      if image and image.classified_post_id == self.id   
        image.destroy
      end      
    end
    def validate
        begin                  
          if self.title.size == 0 or !self.title.match(/\S/)
              errors.add_to_base("Please enter a title that best describes your item")
          end
          if self.description.size > 65535
              errors.add_to_base("Your description must be less than 65535 characters.")
          end
          
        rescue Exception=>e        
        
        end

    end
end
class PostImage < ActiveRecord::Base  
  def src= data
       dir = File.join(RAILS_ROOT,"public/shared_images/classifieds")
       FileUtils.mkdir_p(dir)
       file_path = File.join(dir,"#{self.id}.jpg")
       File.open(file_path,"wb") {|file| file.write(data)}    
  end
  def src
      return "/shared_images/classifieds/#{id}.jpg"
  end
  def before_destroy
      begin
        FileUtils.rm(File.join(RAILS_ROOT,"public/shared_images/classifieds/","#{id}.jpg"))       
      rescue
      
      end
  end
end
class ItemAttributeValue  < ActiveRecord::Base
    belongs_to :post, :class_name=>'ClassifiedPost'
    belongs_to :generic_attribute
    belongs_to :category, :class_name=>'ClassifiedCategory'
    def name
        self.generic_attribute.name
    end
    def _type_
       self.generic_attribute._type_
    end
    def display_position
      self.generic_attribute.display_position
    end
end
