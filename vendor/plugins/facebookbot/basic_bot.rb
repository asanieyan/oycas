#== This Bot
#This simple bot just updates your status based on a random entry in
#rules.txt. You will need to open this file and change the email
#and password it is using.
#== Running Your Bot
#Like so:
#     ruby basic_bot.rb
#But remember to open it up and change the email and password!

require 'facebook_bot/facebook_bot'

random = Random.new
fb = FacebookBot.new({:email => 'asanieya@sfu.ca', :password => 'v3j7n1'})
if !fb.logged_in?
  raise "Unable to login with the provided credentials!" 
end

fb.set_status random.item('STATUS').downcase
fb.get_friends.each do |friend|
  p friend.network_domain
end
