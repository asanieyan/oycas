#This is the FacebookFriend class.
#It is a simple class that just holds friend information.
#You should be simple, too. Being simple, you should have
#nothing to do with this class.. besides create friends with it
#if you so desire. These friends are no substitutes for friends
#in real life
class FacebookFriend
  attr_accessor :id
  attr_accessor :name
  attr_accessor :network_domain
  
  #Creates a facebook friend given three strings: id, name, network_domain.
  #  fb_friend = FacebookFriend.new('3923939', 'Mark Zuckerberg', 'harvard.facebookcom')
  def initialize(id, name, network_domain)
    @id = id
    @name = name
    @network_domain = network_domain
  end
end
