#==About
#Random is a class like no other.
#Random allows you do to fun things like 'random.sentence' and 'random.position'.
#It takes no quarter. It asks for no parameters. 
#== Usage
#  random = Random.new
#For an overview on the Grammar system, please head over to the Grammar class.
#These are just mainly helper functions that interact with Grammar. For example,
#  random.sentence 'SENTENCE'
#That would pull a random SENTENCE line out of your rules.txt, automatically replacing
#capitalized words with their rules.txt counterparts.
#  random.item 'NOUN'
#That function pulls a random NOUN out.
#Some other randomness might randomly be added at a random point in time.
class Random < Grammar
  
  #Generates a random sentence. The parameter it takes
  #is the reference to the Grammar rules entry
  #  random.sentence 'REMARK'
  #  random.sentence 'SENTENCE'
  def sentence start='REMARK'
    replace(@rules[start].random).capitalize
  end
  
  #Sleeps for a random amount of time between min and max
  #  random.sleep 15,30
  def sleep(min=30,max=45)
    raise 'max cannot be less than min' if max < min
    
    seconds_to_sleep = (60*min + rand(60 * (max-min)))
    puts "(#{Time.now.strftime("%H:%M")}) Sleeping for #{seconds_to_sleep/60} mins"
    Kernel.sleep seconds_to_sleep
  end
  
  #Generates a random item, or phrase. This is not capitalized, and is meant
  #for things like profile interests, music, etc. Use random.sentence for sentences.
  #  random.item 'BAND'
  #  random.item 'FRUIT'
  def item kind
    replace(@rules[kind].random)
  end
  
  #Picks a random file out of path.
  #  random.file 'profile_pictures/bunnies'
  def file path
    Dir[path+"/*"].random
  end
  
  #Picks a (skewed) random position array [x,y]. Used for tagging photos at a random spot.
  #  random.position
  def position
    [percentage.to_s[0..5],percentage.to_s[0..5]]
  end
  
  #A skewed percentage between 20 and 75.
  #  random.percentage
  def percentage
    20+rand(55)+rand
  end

  #A random number of specified length. Used for zip codes, phone numbers, etc
  #  random.number 10
  def number length=1
    Array.new(length).collect{rand(10)}.join
  end
  
  #A random ten digit zipcode, yeehaw!
  #  random.zip_code
  def zip_code
    number 5
  end
  
  #A random ten digit phonenumber, yeehaw!
  #  random.phone_number
  def phone_number
    number 10
  end
end