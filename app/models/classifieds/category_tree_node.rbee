class CategoryTreeNode < ActiveRecord::Base
  acts_as_nested_set 
  belongs_to :category, :class_name=>"ClassifiedCategory"
  def self.roots
        self.find(1).roots
  
  end
end
