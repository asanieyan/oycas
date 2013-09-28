#default modules and classes and stuff to include


['net/http','net/https','uri','cgi','rubygems','hpricot','lib/array',
'lib/hash','lib/grammar','lib/random'].each do |required|
  require required
end
Net::HTTP.version_1_2 # "I strongly recommend to call this method always." says Net::HTTP docs!

#FacebookBot stuff to include
['facebook_friend','helper','status','login','friends','wall','messages',
'pictures','profile','groups','poke'].each do |required|
  require "facebook_bot/#{required}"
end

#Oh, so you want to actually make your bot do something cool?
#What a novel idea! The gist of the bot is located somewhere towards
#the end of bot.rb. Here's a good example:
#     fb = FacebookBot.new({:email => 'test@test.com', :password => 'test1234'})
#From there you'll want to do something with your bot. Here's some more examples:
#     fb.set_status 'likes pina-coladas..'
#     fb.change_profile_picture 'cute-puppy.jpg'
#etc etc. Wrap that stuff in a loop, put in a few sleeps, and you've got yourself 
#a FacebookBot. Look all all the FacebookBot methods (via
#modules) to see what you can do. Also check out the EXAMPLES file.
class FacebookBot
  VERSION='0.2.1'
  include FacebookHelper
  include FacebookStatus
  include FacebookLogin
  include FacebookFriends
  include FacebookWall
  include FacebookMessages
  include FacebookPictures
  include FacebookProfile
  include FacebookGroups
  include FacebookPoke
  
  def initialize opts
    @opts = {:headers => {'Content-Type' => 'application/x-www-form-urlencoded',
                          'Cookie' => 'test_cookie=1',
                          'User-Agent' => 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.3) Gecko/20070309 Firefox/2.0.0.3'}}.merge(opts)
    login
  end
  
end