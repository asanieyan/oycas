argv = ARGV; #to get rid of the task passes as argument
argv.shift;
$argv = {}
argv.each do |arg|
  k,v = arg.split("=")
  v = v.split(",").map{|vi| v.intern}
#  v = v.pop if v.size == 1
  $argv[k.intern] = v
end
def in_read
  STDIN.readline.strip
end
def prompt q 
  p q
  in_read
end
def confirm(message)
      message += " [yes|no]"
      p message
      answer = STDIN.readline.strip
      if %w(yes no).include?(answer)
          return answer == "yes"
      end
      while not %w(yes no).include?(answer)
          p 'Please enter with yes or no'
          p message
          answer = STDIN.readline.strip
      end    
      return answer == "yes"
end
