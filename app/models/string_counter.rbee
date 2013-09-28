class StringCounter < ActiveRecord::Base
  #sorts items based on the descending order or their count value
  def self.sort items,&block
    items.each do |item|
      c = block_given? ? count(block.call(item)) : count(item)  
      item.instance_eval <<-eof
        def num_reads
          return #{c}
        end
      eof
    end    
    items.sort! {|a,b| 
      b.num_reads <=> a.num_reads
    }    
    
  end
  def self.add_entry(string)
    if counter = self.get_counter(string)
     counter.count += 1
     counter.save
    else
      counter = StringCounter.create(:string_entry=>string,:count=>1) 
    end
    return counter
  end
  def self.get_counter(string)
    self.find(:first,:conditions=>"string_entry LIKE '#{string}'")
  end
  def self.count(string)
    get_counter(string).count rescue 0
  end
end
