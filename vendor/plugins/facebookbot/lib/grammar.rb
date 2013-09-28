#==About
#This is the brains behind the whole operation. It gives FacebookBot the ability to
#speak and therefore interact with its friends and foes alike.
#==Usage
#You create a Grammar instance as follows:
#  grammar = Grammar.new({:rulesfile => 'test.txt'})
#It takes a hash of options as its parameter. Right now
#the only option available is the rulesfile. You can change the path to the rulesfile,
#but by default it is just 'rules.txt.' It looks for a file full of lines like this:
#  ADJECTIVE-->blue
#  ADJECTIVE-->soft
#  ADJECTIVE-->dumb
#  VERB-->run
#  VERB-->eat
#You get the point. It creates a hash of @rules for later parsing. The hash has the capitalized words
#as its keys and Arrays of strings as its values. Example:
#  @rules = {'ADJECTIVE' => ['blue','soft','dumb'], 'VERB' => ['run','eat']}
#You can do all sorts of nice things with this ruleset. The biggest and
#perhaps most important feature is its recursion. You can do things like this:
#  SENTENCE-->You're a ADJECTIVE-headed freak!
#And it will auto-magically replace ADJECTIVE with a random adjective
#if you call the replace function. This is most extensively
#used in the Random class (which inherits this one), so maybe you should
#go peek your head over there.
class Grammar

  #Sets up a Grammar instance. Look at the docs (perhaps just look up!) for more info.
  def initialize opts={}
    @opts = {:rulesfile => 'rules.txt'}.merge(opts)
    @rules = {}
    
    IO.foreach(@opts[:rulesfile]) do |rule|
      next unless rule =~ /\S+/
      rule.gsub!(/\s+$/,'');
      if rule =~ /^(.*)-->(.*)$/
        @rules[$1] = [] if @rules[$1].nil?
        @rules[$1] << $2
      end
    end
  end
    
  #Replace capitalized words with a random entry from @rules, if there is one.
  #Check it out: it's recursive and simple and beautiful.
  def replace line
    line.gsub(/(\b[A-Z]{2,}\b)/) {|match|
      @rules.has_key?(match) ? replace(@rules[match].random) : match
    }
  end
    
end
