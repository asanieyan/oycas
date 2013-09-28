desc "Load the user reports into database"
task :init_app do 
  #must be run only one time after deployment
  #must initialize the tables
  #must load admins,user_reports,networks, categories 
  p 'creating initial database'
  unless system "mysql -u root  -p123 <db/create.sql"
    fail "App has been initiated before. You must remove the db manualy first"  
  end
  p 'loading migration'
  Rake::Task['migrate'].invoke;
  p 'loading user reports'
  Rake::Task['user_reports'].invoke;
  p 'loading admins'
  Rake::Task['load_admins'].invoke;    
  p 'loading networks'
  Rake::Task['update_networks'].invoke;     
  p 'loading classifiies categories'
  Rake::Task['load_classifieds'].invoke; 

end
task :user_reports => :environment do
    ReportReason.load_from_yml(YAML::load_file('lib/admin/user_reports.yml'))    
end
desc "Load admins from the admins.yml file"
task :load_admins => :environment do
     admins = YAML::load_file('lib/admin/admins.yml')
     admins.each do |admin|
        begin         
          fname,lname = admin['name'].split(" ",2)
          fail "admin needs a first name" unless fname
          fail "admin needs a last name" unless lname
          fail "admin needs an email" unless admin['email']
#          fails "admin needs a password" unless admin['pass']
          a = Admin.new(:confirmed=>:y,:first_name=>fname,:last_name=>lname,:email=>admin['email'])
          a.password= ENV['RAILS_ENV'] == "production" ? 'bestof$$$123' : '123'
          a.save 
          p "created an admin: " + a.inspect
        rescue Exception=>e   
          p e.message
          next
        end
     end
end
desc "Upading country, regions and networks reading it from the regions.yml file"
task :update_networks => :environment do   
  y = YAML::load_file('lib/admin/networks.yml')
  y.each do |country,regions|  
      require 'network.rb'
      p country.titlecase
      c = Country.find_or_create_by_name(country.dup)
      regions.each do |region,networks|
        p "  " + region.titlecase      
        s = SubRegion.find_or_create_by_name_and_country_id(region.dup,c.id)
        networks.each do |network|
          p "    " + network.titlecase
          Network.find_or_create_by_name_and_sub_region_id(network.dup,s.id)
        end
      end
  end
end
desc "set pictures for dummy students one by one"
task :dummy_profile_images => :environment do 
    force = $argv[:force].pop == :true rescue false
    Student.find(:all,:conditions=>"rank LIKE 'dummy'").each do |s|
        unless s.profile_image_set and not force
          
        end
    end 
end
desc "create student accounts for a certain schools"
task :new_accounts => :environment do
  fail "specify the school name" unless $argv[:schools] 
  students = YAML::load_file('lib/admin/students.yml')
  $argv[:schools].each do |school|
    s = School.find_by_short_name(school)
    next unless s
    p 'creating students for school ' + school.to_s
    students.each do |student|                   
        begin
          f_name,l_name = student['name'].split(" ",2)   
          password = ENV['RAILS_ENV'] == "production" ? 'P4n7h3R' : '123'
          new_student = Student.create_new(f_name,l_name,student['email'],password,s)
          p "created student '#{new_student.full_name}' with username '#{new_student.username}'"
        rescue Exception=>e
          new_student = StudentContactEmail.find_by_contact_email(student['email']).student
          p "#{new_student.full_name} already exists as a #{new_student.rank}"
        end
    end
    break #just do one school at a time;
  end  
end
desc "create dummy students for a certain schools"
task :dummy_students => :environment do 
  fail "specify the school name" unless $argv[:schools] 
  dummies = []
  if $argv[:names]      
      namefile = "lib/admin/" + ($argv[:names]).pop.to_s  + ".txt"
      names = (File.new(namefile,"r").read).split(" ")
      size = ($argv[:size] || 15).to_i
      size.times do 
        dummies << {'name'=>names.delete_at(rand(names.size)).downcase + " " + names.delete_at(rand(names.size)).downcase}
      end
  else
    fail "you need to specify a name file"
    #  
  end
  $argv[:schools].each do |school|
    s = School.find_by_short_name(school)
    next unless s
    p 'creating students for school:' + school.to_s
    dummies.each do |dummy|                   
        begin
          f_name,l_name = dummy['name'].split(" ",2)          
          student = Student.create_dummy(f_name,l_name,s,dummy['email'])
          p "created dummy student '#{student.full_name}' with username '#{student.username}'"   
        rescue Exception=>e
          student = StudentContactEmail.find_by_contact_email(dummy['email']).student          
          p "#{student.full_name} already exists as a dummy student"
        end
    end
    break #just do one school at a time;
  end
end
