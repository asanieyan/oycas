#These are some extension functions for the Hash class
class Hash
  
  #Pull out a random key out of a hash
  def random_key
    keys.random
  end
  
  #Pull out a random value out of a hash
  def random_value
    values.random
  end
  
  #Pull a random key/value pair out of a hash
  def random_pair
    key = random_key
    {key => self[key]}
  end
  
  #Pull between min and max random key/value pairs out of a hash
  def random_pairs min=1,max=3
    max = size if max > size
    min = 1 if min < 1
    new_hash = {}
    arr = Array.new(min+rand(max-min+1))
    arr.each{|x| new_hash.update(random_pair)}
    new_hash
  end
  
end