#Extensions to the Array class. Very simple.
class Array
  #pull out a random element from array.
  #  ['a','b','c'].random
  def random
    self[rand(self.length)]
  end
  
  #pull out a random number of elements between min and max from array.
  #  ['a','b','c'].random_values 1,2
  def random_values min,max
    max = size if max > size
    min = 0 if min < 0
    Array.new(min+rand(max-min+1)).collect{|x| random}
  end
  
  #merge arr into a random position into the current array.
  #  ['a','b','c'].merge_randomly(['d','e'])
  def merge_randomly arr
    # get rid of blank items (compact doesn't handle '')
    arr = arr.reject{|x| x.nil? || x == ''}
    rand_pos = rand(self.length)
    self[0..rand_pos] | arr | self[rand_pos..self.length]
  end
    
  #pull a random element out of an array that is not one of the ones specified
  def random_not_one_of arr
    (self - arr).random
  end
  
end