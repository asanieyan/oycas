#require File.join("../..","config/environment.rb")
def parse argv,options
   fail "You can't run this task in the production environment" if ENV['RAILS_ENV'] == "production"   
   require 'yaml'  
   fail "enter schools like schools=x,y,z" if not argv or argv.size == 0   
   argv.each do |school|
    sdir = File.join(File.dirname(__FILE__),"../school/schools/#{school}")
    p 'loading ' + "#{sdir}/#{school}_config.yml"
    config = YAML::load_file("#{sdir}/#{school}_config.yml")
    school_file = sdir + "/" + school.to_s + ".yml"
    unless false #File.exists?(school_file) or true
      File.open(school_file, 'w' ) do |out|
         YAML.dump({:school=>config['school'],:semester_seasons=>config['semester_seasons']}, out) 
      end           
    end
    parser = options[:parser]
    parser.debug = options[:debug]      
    rules = options[:rules]    
    rules = options[:rules] + "_" + options[:version].to_s if options[:version] 
    rules = config[options[:rules]]
    out_file = sdir +  "/#{school}_#{options[:rules]}.yml"
    if File.exists?(out_file) and not confirm("#{school}_#{options[:rules]}.yml already.you must delete this file first. "+ '                   ' + "Delete file?")
        next
    end
    rules.each do |rule|
          parser.parse(rule['url'],rule['parse_options'])       
    end               
    p "saving school #{options[:rules]} into " +  out_file
    File.open(out_file, 'w' ) do |out|       
       YAML.dump({options[:rules]=>parser.yaml_it}, out) 
    end      
   end   
end
desc "parse a new teachers for a school" 
task :parse_teachers do |t|    

     require 'lib/school/lib/teacher_parser'       
     parse($argv[:schools],{:parser=>TeacherParser.new,:rules=>'teachers',:version=>$argv[:ver],:debug=>$argv[:debug]});
end
desc "parse a new school" 
task :parse_courses do |t|
     require 'lib/school/lib/school_parser'
     parse($argv[:schools],{:parser=>SchoolParser.new,:rules=>'courses',:debug=>$argv[:debug]});
end

def set_directory
  sdir = File.join(File.dirname(__FILE__),"../school/schools/#{school_shortname}")
  Dir.chdir(sdir)
end


desc "Add new schools to the db. As argument enter the school code like sfu this task will use sfu.yml in the school/schools/sfu/sfu.yml to add the new school"
task :add_schools => :environment do |t|
   require 'school/lib/school_config.rb'   
   fail "enter the name of the schools like schools=x,y,z" unless $argv[:schools]
   $argv[:schools].each do |school_shortname|
        configurator = SchoolConfigurator.new(school_shortname,ENV["RAILS_ENV"])
        if  configurator.school_model
         fail "school already exists use other tasks to update the school"
        else
          configurator.create_school
        end 
        if confirm "reset school?"
          configurator.school_model.destroy
        end
   end
end
desc "Update the schools semester to their current semester must be run once a month to ensure that all the semesters are up to date"
task :update_semesters => :environment do |t| 
      require 'school/lib/school_config.rb'   
      School.find(:all).each do |school|
          configurator = SchoolConfigurator.new(school.short_name) 
          configurator.update_school_semesters
          
      end
 
end
#task :reset_schools => :environment do |t|
#       School.find(:all).each do |school|
#          school.destroy
#      end
#end
