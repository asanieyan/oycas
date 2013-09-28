require File.join(File.dirname(__FILE__),'general_parser.rb')

class TeacherParser < GeneralParser
    def initialize  
        super       
        @teachers = Array.new
    end  
    def analyze_block elements         
#        elements[:name] = (elements[:first_name] + " " + elements[:last_name]) rescue elements[:name]
        if elements[:first_name] and elements[:last_name]
          elements[:name] = elements[:first_name] + " " + elements[:last_name]
        end
        if elements[:name]
          t = @teachers.find{|t| t.name == elements[:name]}
          unless t          
            p 'adding new teacher ' + elements[:name] if @debug
            @teachers << (t=Teacher.new(elements[:name])) 
          end         
          t.add_email elements[:email],elements[:host]          
          if elements[:photo]
            p 'adding photo ' + elements[:photo] if @debug
            t.photo = elements[:photo]
          end
              
        end    
    end
    def yaml_it    
       @teachers.map{|t| {:first_name=>t.first_name,:last_name=>t.last_name,:email=>t.email,:photo=>t.photo}}
    end
end
class Teacher 
    attr_accessor :name,:photo,:email,:first_name,:last_name
    def initialize (name)
        @name = name
        @name.gsub!(/Dr\./,'')
        @first_name,@last_name = name.split(" ",2)
        @first_name.strip! rescue nil
        @last_name.strip! rescue nil
    end 
    def photo= photo
      if photo.include?('nophoto')
        photo = ""
      elsif photo.include?("/index.html/")      
        photo.sub!(/\/index.html\//,"\/")
      end
      @photo = photo
    end
    def add_email email,host=nil
       if email and host
          self.email=email +"@"+host
       elsif email
          self.email=email
       end
    end
end
