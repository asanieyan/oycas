require File.join(File.dirname(__FILE__),'general_parser.rb')

class SchoolParser < GeneralParser
     attr_accessor :subjects,:course_locations    
     def initialize  
        super       
        @subjects = Array.new
     end  
     def report
              
     end 
     def yaml_it
        t = Array.new
        @subjects.each do |subject|
              (_subject_ = {:name=>subject.name,:code=>subject.code})
              _subject_[:courses] = Array.new
              subject.courses.each do |course|
                  _subject_[:courses] << {:subject=>course.subject,:name=>course.name,:description=>course.description,:number=>course.number,:credit=>course.credit}
              
              end              
              t << _subject_
        end
        return t
     end
     def analyze_block elements                 
          subject_name = (elements[:subject_name] || "").gsub(/\s+/,' ')
          code = (elements[:code] || "").gsub(/\s+/,' ')
          name = (elements[:name] || "").gsub(/\s+/,' ')
          desc = (elements[:desc] || "").gsub(/\s+/,' ')          
          credit = (elements[:credit] || "").gsub(/\s+/,' ')
          number = (elements[:number] || "").gsub(/\s+/,' ')            
            if subject_name.length > 0 or code.length > 0           
                s = @subjects.detect {|subject| 
#                               puts "looking for '#{code}' '#{subject_name}' now checking: " + subject.subject_name + " "  + subject.code  if @debug
                      (subject.code == code and code.length > 0) || (subject.name == subject_name and subject_name.length > 0)
                }
                if (not s)                           
                      puts "creating subject '#{code}'  '#{subject_name}'"  if @debug                                                    
                      s = Subject.new(code, subject_name)
                      @subjects << s                           
                elsif (s.code != code and code.length > 0)
                    puts "updating subject '#{s.name}' code to '#{code}'" if @debug
                    s.code = code;
                elsif (s.name != subject_name and subject_name.length > 0)
                    puts "updating subject '#{s.code}' name to '#{subject_name}'" if @debug
                    s.name = subject_name
                end                  
               if (number != "" or name != "")
                      c = s.find_and_update number,name,desc,credit                      
                      if c 
                           puts "updating course '#{number}'  '#{name}' \n '#{desc}'"    if @debug 
                      else
                           puts "creating course '#{number}'  '#{name}' \n '#{desc}'"    if @debug 
                            c = Course.new s.code,number,name,desc,credit
                            s.add_course c                         
                      end
                end
             end                       

   end
end
class Subject

    attr_accessor :code, :name , :courses
    def initialize code,subject_name
        @code = code
        @name = subject_name
        @courses = Array.new
    end
    def find_and_update number,name,desc,credit
        return nil if @courses.length == 0        
        course = @courses.detect {|course| (course.number == number and number.length > 0) or
                    (course.name == name and name.length > 0)                     
                     
        }
        if course
            course.number = number if number.length > 0
            course.name = name if name.length > 0
            course.description = desc  if desc.length > 0
            course.subject = self.code
            course.credit = credit if credit.size > 0
        end 
        return course   
    end
    def add_course course
          unless @courses.include? course
                @courses << course
          end
          
    end
end
class Course
    attr_accessor :name,:number,:description,:subject,:credit
     def initialize  subject, number,name, desc,credit      
          
          @number = number
          @name = name
          @description = desc
          @subject = subject
          @credit = credit
    end   
end
