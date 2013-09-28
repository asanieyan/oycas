module GUID #add some functionality related to guid field of an activerecord object if they have any
    def self.included(base)
        base.extend(ClassMethods)
        base.send :include, InstanceMethods

    end
    module ClassMethods 
            def has_guid_field options={}
                  if options[:uniq]
                    @very_unqi_gui = true
                    @class_name = "UniqGuid"
                  else
                    @very_unqi_gui = false
                    @class_name = "self"                    
                  end
                  
                  field_name = options[:field] || :guid
                  #field_name = field_name.to_s
                  attr_protected field_name
                  before_save :set_guid
            end
            def get_guid
                #get a unique number between 999999999999999999 and 100000000000000000
               guid_is_unique = false
               while not guid_is_unique do
                  guid = rand 999999999999999999
                  guid = 100000000000000000 + guid if guid < 100000000000000000
                  guid_is_unique = true if not class_eval(@class_name).find_by_guid(guid)       
#                  logger.debug "generated guid = #{guid.to_s} : unique #{guid_is_unique.to_s}"
               end
               UniqGuid.create :guid=>guid if @very_unqi_gui
               return guid     
            end            
    end
    module InstanceMethods
           def set_guid
                if ((self.guid || 0) == 0)
#                    logger.debug "during manual set #{self}: no guid, generating one"                    
                    self.guid = self.class.get_guid                 
                end
           end    
    end
end