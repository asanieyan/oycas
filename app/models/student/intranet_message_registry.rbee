class IntranetMessageRegistry <  ActiveRecord::Base
    belongs_to :reciever, :class_name=>"Student", :foreign_key =>'reciever_id'
    belongs_to :message_record,:class_name=>'IntranetMessage',:foreign_key =>'intranet_message_id'
    def folder
      read_attribute(:folder).to_s
    end
end
