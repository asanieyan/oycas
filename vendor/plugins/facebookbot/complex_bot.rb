#== This Bot
#This bot is a primo example of what you can do! It unfurls fury on your
#Facebook profile, so watch out! It is a complicated bot that does a lot
#to your Facebook profile. This is the bot I run on my Facebook. Yee-haw!
#In order for this bot to work properly, it needs some images to make your
#profile picture change randomly. Check out this line:
#    fb.change_profile_picture random.file('profile_pictures/ducklings')
#You'll have to change that to a path where there are images (JPGs) so it can
#choose one at random.
#== Running Your Bot
#Like so:
#    ruby complex_bot.rb
#You can also see the parameters it accepts with:
#    ruby complex_bot.rb -h
#But here are some good examples to follow:
#    ruby complex_bot.rb -e you@fb.edu --password=cool4
#    ruby complex_bot.rb -e test@test.edu
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
  o.on("-d", "--debug", "Debug Mode?")   { |OPTIONS[:debug]| }

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

#lets exclude some friends from getting stuff done to them.
friends = friends.reject{|x| [919829,1813502,921792,1817956,4603386].include?(x.id.to_i)}

#the actual bot does a few things.
if OPTIONS[:debug] == false
  loop do  
    fb.wall_post friends.random, random.sentence('SPREE')
    fb.poke friends.random
    3.times do |i|
      fb.add_friend fb.find_random_friend
      fb.change_profile_picture random.file('profile_pictures/ducklings')
      fb.tag_profile_picture 'self', random.position
      random.sleep 15,30
      fb.join_group(fb.find_group(random.item('GROUPSEARCH')))
      random.sleep 15,30
      fb.set_status random.item('STATUS').downcase
      random.sleep 15,30
      fb.add_profile_info('personal',{
        'interests' => random.item('INTEREST'),
        'music' => random.item('BAND'),
        'tv' => random.item('TVSHOW'),
        'movies' => random.item('MOVIE'),
        'books' => random.item('BOOK'),
        'clubs' => random.item('ACTIVITY'),
        'quote' => random.item('QUOTE')}.random_pair)
      random.sleep 15,30
      fb.add_profile_info('basic',{
        'meeting_sex1' => 'on',
        'meeting_sex2' => 'on',
        'relationship' => rand(6)+1,
        'meeting_for1' => 'on',
        'meeting_for2' => 'on',
        'meeting_for3' => 'on',
        'meeting_for4' => 'on',
        'meeting_for5' => 'on',
        'birthday_month' => rand(12)+1,
        'birthday_day' => rand(28)+1,
        'hometown' => random.item('CITY'),
        'hometown_region' => rand(50)+1,
        'hometown_country' => 398,
        'political' => rand(9),
        'religion_name' => random.item('RELIGION')}.random_pairs(5,10))
      random.sleep 15,30
      fb.add_profile_info('contact', {
        'mobile' => random.phone_number,
        'other_phone' => random.phone_number,
        'school_mailbox' => rand(4030),
        'room' => rand(32),
        'city' => random.item('CITY'),
        'region' => rand(50)+1,
        'zip' => random.zip_code}.random_pairs(5,10))
      random.sleep 15,30
      fb.add_profile_info('contact',{
        'new_sn_0' => random.item('SCREENNAME').gsub(' ',''),
        'sn_serv_0' => rand(7)+1})
      random.sleep 1,5
      fb.remove_profile_info('contact',['mobile','other_phone','school_mailbox'].random_values(1,3))
      random.sleep 1,5
      fb.remove_profile_info('basic',['meeting_sex1','meeting_sex2',
        'relationship','meeting_for1',
        'meeting_for2','meeting_for3',
        'meeting_for4','meeting_for5',
        'birthday_month','birthday_day',
        'hometown','hometown_region',
        'hometown_country','political',
        'religion_name'].random_values(3,5))
    end
  end
else # some debugging stuff goes here. anything you want, big guy, its yours, all yours!
  
end