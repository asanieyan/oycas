#== This Bot
#This bot is an example of what FacebookBot can do. It logs into facebook
#with your provided credentials, and then proceeds to poke one of
#your friends at random, and then changes your status randomly.
#This is a good beginning to build your own bot.
#== Running Your Bot
#Like so:
#    ruby bot.rb
#You can also see the parameters it accepts with:
#    ruby bot.rb -h
#But here are some good examples to follow:
#    ruby bot.rb -e you@fb.edu --password=cool4
#    ruby bot.rb -e test@test.edu
require 'optparse'
require 'facebook_bot/facebook_bot'

# default options
OPTIONS = {
  :email => nil,
  :password => nil,
  :debug => false
}

ARGV.options do |o|
  script_name = File.basename($0)
  o.set_summary_indent('  ')
  o.banner =    "Usage: #{script_name} [OPTIONS]"
  o.define_head "FacebookBot #{FacebookBot::VERSION}.\n" +
  "Use for good, not evil."
  o.separator   ""
  
  o.on("-e", "--email=val", String,
       "Facebook Email Address")   { |OPTIONS[:email]| }
  o.on("-p", "--password=val", String,
            "Facebook Password (caSE SenSITive)")   { |OPTIONS[:password]| }

  o.separator ""

  o.on_tail("-h", "--help", "Show this help message.") { puts o; exit }
  
  o.parse!
end

if OPTIONS[:email].nil?
  print "Please enter your email address: "
  OPTIONS[:email] = gets
end

if OPTIONS[:password].nil?
  print "Please enter your password: "
  OPTIONS[:password] = gets
end

random = Random.new
fb = FacebookBot.new({:email => OPTIONS[:email].chomp, :password => OPTIONS[:password].chomp})
if !fb.logged_in?
  raise "Unable to login with the provided credentials!" 
end

#lets grab our friends!
friends = fb.get_friends

loop do
  #poke a random friend
  fb.poke friends.random

  #change my status
  fb.set_status random.item('STATUS').downcase
  
  #go to sleep for a random amount of time between 15 and 30 minutes.
  random.sleep 15,30
end
