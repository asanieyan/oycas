class StudentProfile < ActiveRecord::Base
  belongs_to :student
  
  #make sure their valus corresponds to the enum values within the table 
  validates_columns   :political_views, :religious_views
  #make sure their values are between 0 and 5 because we only have 0 to 5 level of visibility 
  validates_inclusion_of :im_visibility,:mobile_phone_visibility,:land_phone_visibility,:residence_room_visibility,
                         :address_visibility,   :in=>0..5

  
  before_save :set_profile
  def before_create
      self.attributes.each do |k,v|
          if k =~/visibility$/
            self[k] = student.profile_visibility
          end
      end
  end
  def visibility
      profile_visibility
  end  
 
  def set_profile
      #general_information      
      self.class.send :include,ActionView::Helpers::TagHelper
      attributes.each do |key,value|          
          if value.is_a? String              
              value = escape_once value
              value.gsub!(/^\s*(\S*)\s*$/,'\1')                                                  
              send key+"=", value                                      
          end          
      end
      begin 
        raise if (self.country || "").size == 0          
        if self.country == "Canada"
          raise  unless StudentHelper::CANADA_PROVINCES.include? self.sub_region
        elsif self.country == "United States"
          raise  unless StudentHelper::US_STATES.include? self.sub_region
        else
           self.sub_region = nil
           raise unless ActionView::Helpers::FormOptionsHelper::COUNTRIES.include?(self.country)
        end        
      rescue 
         self.country = nil;self.sub_region = nil;      
      end
  end  
end
