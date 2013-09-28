class ClassifiedCategory < ActiveRecord::Base
 # has_many :posts , :class_name=>'ClassifiedPost'
  has_one :node, :class_name=>"CategoryTreeNode"
  has_many :attribute_category_maps
  has_many :generic_attributes , :through=>:attribute_category_maps
  def select_name;self['select_name'] || self['name'];end
  def post_query_sql_constructor network, options
      sql_options = {}
      post_sql = []    
      if (search_value = (options[:title] || "").strip).size > 0         
        or_clauses = []        
#       NO SUPPORT FOR COURSE OR SUBJECT ASSOCIATION
#        if self.associable_to and search_value.size >= 3 and search_value =~ /\w+{2}/
#               or_clauses <<   ClassifiedCategory.send(:sanitize_sql ,["associated_names LIKE ?", "%" + search_value + "%"])     
#        end
        or_clauses <<  ClassifiedCategory.send(:sanitize_sql ,["title LIKE ?", "%" + search_value + "%"])        
        post_sql << or_clauses.join(" OR ")
        
      else
          options[:title] = nil
      end
      if (options[:school_id].to_i > 0)
        #TODO : check this school_id is valid meaning it must belong to this network
        post_sql << "school_id = #{options[:school_id]}"
      end
      attribute_sql = []
     if options[:min] or options[:max]
         min = options[:min].to_i 
         max = options[:max].to_i == 0 ?  Float::MAX : options[:max].to_i         
         min,max = max,min if min > max
         attribute_sql << "attrb_1_value BETWEEN #{min} AND #{max}"
         options[:min] = min == 0 ? nil : min
         options[:max] = max == Float::MAX ? nil : max
         
     end
     (options[:attributes] || {}).each do |position,attrb_search_value|
          if (attrb_search_value || "").size > 0
            #i had to remove "%" + attrb_search_value + "%" from query below 
            #because this pattern gets confused for words that are contained in other words like men in women
            attribute_sql <<  ClassifiedCategory.send(:sanitize_sql ,["attrb_#{position}_value LIKE ?", attrb_search_value ] )    
          end
      end        
      
      scope =  "network_id = #{network.id}"
      attribute_sql = attribute_sql.join(" AND ")
      post_sql = post_sql.join(" AND ")
      sub_categories_sql = " classified_posts.classified_category_id IN ( " + self.node.leafs.map{|n| n.classified_category_id }.join(",") + " ) "      
      if attribute_sql.size > 0 #if there are any attribute query 
        sql_options[:joins] =  "INNER JOIN item_attribute_values ON classified_posts.id = item_attribute_values.classified_post_id"
      end
      sql_options[:select] = "DISTINCT classified_posts.*"
      sql_options[:conditions] = ([scope,post_sql,sub_categories_sql,attribute_sql].find_all{|e| e.size == 0 ? false : true }).join(" AND ")
      sql_options[:order] = "created_on DESC"
      return sql_options
      #
  end 
  def count_posts_for network,options={}
      sql_options = post_query_sql_constructor network,options
      begin 
        return ClassifiedPost.count(sql_options.merge(:select=>"DISTINCT classified_posts.id"))        
      rescue Exception=>e
        logger.debug e.message
      end
  end
  def posts_for network, options={}
      sql_options = post_query_sql_constructor network,options
     
      posts = ClassifiedPost.find(:all, sql_options)                    
  end 
  def has_attribute _attribute_id
        #check whether this category is mapped to any attribute with the attribute_id
        #if it is mapped it will return the attribute object after 
        #having its position_index
        
        rec = AttributeCategoryMap.find_by_classified_category_id_and_generic_attribute_id self.id,_attribute_id        
        if rec
            ga = rec.generic_attribute
            ga.category_position = rec.attribute_index
            rec = ga
        else
            rec = nil
        end
        return rec
  end
  def searchable_attributes
      @category_searchable_attributes ||= GenericAttribute.find( :all,:select=>"DISTINCT generic_attributes.*, attribute_category_maps.attribute_index AS category_position",
                      :joins=>"INNER JOIN attribute_category_maps ON attribute_category_maps.generic_attribute_id = generic_attributes.id",
                      :conditions=>"classified_category_id = #{id} AND searchable LIKE 'y'"
                      
                      )          
  end
  def listable_attributes
      @category_listable_attributes ||= GenericAttribute.find( :all,:select=>"DISTINCT generic_attributes.*, attribute_category_maps.attribute_index AS category_position",
                      :joins=>"INNER JOIN attribute_category_maps ON attribute_category_maps.generic_attribute_id = generic_attributes.id",
                      :conditions=>"classified_category_id = #{id} AND listable LIKE 'y'"
                      
                      )          
  end  
  def add_attribute  attrb
      name_and_options = attrb.shift.dup
      options = {}
      if name_and_options.is_a? Array #that means some options passed for this attribute type        
        #needs to duplicate the the array
        name = name_and_options.shift       
        name_and_options.each do |option|
            key, value = option.split(":") 
            options[key] = value                                                         
        end              
      else        
        name = name_and_options      
      end
      type = attrb.shift    
      if type =~ /multiple/
          options["searchable"] = options["searchable"] || 'y'
      else          
          options["searchable"] = options["searchable"] || 'n'          
      end

      generic_attribute_attributes = {:name=>name, :_type_=>type}.update(options)      
      ga = GenericAttribute.find_or_create(generic_attribute_attributes,attrb)

      attrb_index = AttributeCategoryMap.count(:conditions=>"classified_category_id = #{self.id}") + 1
#      if self.name == 'Monitor/Display' or self.name == 'Desktop PCs'
        p "adding '#{name}' attribute of type '#{type}' to the '#{self.name}' category with position : #{attrb_index} " 
#      end
      #TODO: AttributeCategoryMap should not map an attribute to a category more than one time 
      #or should it ? I don't know yet 
      #
      AttributeCategoryMap.create :classified_category_id=>self.id,:generic_attribute_id=>ga.id,
                                  :attribute_index=>attrb_index
        
  end  
end
class GenericAttribute < ActiveRecord::Base
    has_many :attribute_category_maps
    has_many :values , :class_name=>'AttributeValidity'
    
    attr_accessor :category_position
    
    def category_position
          return @category_position || self[:category_position]
    end
    def self.find_or_create(attrbs,mvalues)
      sql = []      
      attrbs.each do |key,value|
            next if key == "check_pattern" #don;t compare pattern
            sql << "#{key} = '#{value}'"
      end
      sql = sql.join(" AND ")
      ga = self.find(:first, :conditions=>sql)      
      if ga and (ga._type_.to_s.include? "multiple" ) #if the attribute is a multiple make sure that the multiple values are also the same 
            vals = ga.values.map{|v| v.valid_value }            #            
#            puts mvalues.inspect
#            puts vals.inspect
#            puts mvalues == vals
            ga = nil unless vals == mvalues             
      end #if didn't find ga then create a new one 
      unless ga
          ga = GenericAttribute.create(attrbs)rescue fail  
#          puts "creating '#{ga.name}' attribute of type '#{ga._type_}'" 
          if ga._type_.to_s.include? "multiple"
                mvalues.each do |value|
                    AttributeValidity.create :generic_attribute_id=>ga.id,:valid_value=>value
                end            
    #      elsif type == 'float' or type == 'currency'
    #          attrb <<  "0.." if attrb.empty? #all ranges from 0 to max 
    #          attrb.each do |range|
    #              ga.add_float_range range
    #          end            
          end             
      else
#            puts "found an exsiting '#{ga.name}' attribute of type '#{ga._type_}'" 
      end      
      return ga
    end

    def add_float_range range
        min,max = extremities_of :float,range
        scope = "generic_attribute_id = #{self.id}"
        #if found a range that already covers this range then don't add this range pointless
        return if AttributeValidity.find(:first, :conditions=>" #{scope} AND min_range <= #{min} AND max_range >= #{max}")                
        #delete any range that is within this new range 
        AttributeValidity.destroy_all(" #{scope} AND min_range >= #{min} AND max_range <= #{max}")        
        #overlap record
        rec = AttributeValidity.find(:first, :conditions=>"#{scope} AND (#{min} <= max_range AND #{max} >= max_range OR " + 
                                                                        "#{min} <= min_range AND #{max} >= min_range )")

        if rec 
              if min <= rec.max_range and max >= rec.max_range 
                  min = rec.min_range                  
              else
                  max = rec.max_range
              end
              #destroy the overlapped reocord 
              rec.destroy        
        end
        AttributeValidity.create :generic_attribute_id=>self.id,:min_range=>min,:max_range=>max
    end
    
    #this method validates the value entered based on its attribute type
    def validify value_ptr,params
        value_ptr[0] = "" unless  value_ptr[0] =~ /\S/
        value = value_ptr[0]
        #logger.debug("checking value for #{self.name} : #{value}")                
        if self._type_ == :date
            value = value_ptr[0] = "" if value_ptr[0] == "mm/dd/yy"
        end
        if self._type_ == :address
            value = value_ptr[0] = (params[:street] || "") + (params[:city] || "") + (params[:postal_code] ||"").upcase        
        end
        unless value and value.to_s.size > 0 #if the value is empty
           if self.required.to_s == 'y'#if the value is mandetory
             if self.blank_err 
               errors.add_to_base(self.blank_err)
             else           
               errors.add_to_base("Please enter a value for #{self.name.downcase}")
             end
           end
           return              
        end
        _type_ =  self._type_.to_s
        case _type_
            when "multiple","multiple_with_input"                
                  valid_value = self.values.map{|value_rec| value_rec.valid_value }.include?(value)
                  if not valid_value and _type_ == "multiple"
                      errors.add_to_base "has invalid value" 
                  elsif _type_ == "multiple_with_input" and not value =~ /#{check_pattern}/
                     errors.add_to_base format_err || "Please enter a valid value for #{name}"
                  end
                
            when 'date'
                 errormsg = ""
                 
                 if value.match(/\d\d?\/\d\d?\/\d\d(\d\d)?/)
                      month,day,year = value.split("/")
                      begin                       
                          t = Time.utc(year,month,day)  #store the time in server timezone                           
                          if t.to_date >= $my.time(Time.now.utc).to_date
                            value_ptr[0] = t.to_i 
                          else                             
                            errormsg =  "Please enter date in the future"                          
                          end                          
                      rescue  Exception=>e
                        
                          errormsg =  "Please enter a valid date"
                      end
                                            
                 else                 
                    errormsg = "Please enter a date in the format of mm/dd/yy" 
                 end
                 if errormsg.size > 0
                    errormsg += " or leave the date field blank" unless self.required == :y
                    errors.add_to_base errormsg
                 end                 
            when 'boolean'
                errors.add_to_base("This checkbox value is corrupted. Please Refresh Screen") unless value_ptr[0] == self.name
            when "currency"        
                 value_ptr[0].strip!                  
                 value = value_ptr[0]
                 if value.match(/^\d+(\.\d+)?$/)                
                       value_ptr[0].gsub!(/(\.\d\d)\d+/,'\1')
                 else
                     errors.add_to_base "Please enter a valid #{self.name.downcase}" 
                     
                 end
            when "address"           
                value_ptr[0] = (params[:street] || "") + "###" + (params[:city] || "") + "###" + (params[:postal_code] ||"").upcase  
        end        
    end

end
class AttributeValidity < ActiveRecord::Base
  

end
class AttributeCategoryMap < ActiveRecord::Base
  belongs_to :classified_category
  belongs_to :generic_attribute
  def self.find_map_index category,attrb
      category_id = if category.is_a?(ClassifiedCategory)
                       category.id
                    else
                       category.to_i
                    end
                    
      attrb_id = if attrb.is_a?(GenericAttribute)
                     attrb.id
                 else
                    attrb.to_i
                 end
      @map_hash ||= {}
      unless (@map_hash["#{category_id},#{attrb_id}"])            
            @map_hash["#{category_id},#{attrb_id}"] = AttributeCategoryMap.find(:first, :conditions=>"classified_category_id = #{category_id} AND generic_attribute_id = #{attrb_id}")                        
      end
      return @map_hash["#{category_id},#{attrb_id}"]                          
  end

end
