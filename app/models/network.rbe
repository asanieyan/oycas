class Country < ActiveRecord::Base
# has_many :schools
  def before_create 
      self.name.downcase!
  end
end
class SubRegion < ActiveRecord::Base
  belongs_to :country
  def before_create 
      self.name.downcase!
  end
#  has_many :schools

end
class Network < ActiveRecord::Base
  has_many :schools
  belongs_to :sub_region
  def before_create 
      self.name.downcase!
  end 
  def title
    self.name.gsub('_'," ").titleize
  end
end
