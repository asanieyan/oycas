namespace :development do 
  task :check_environment=>:environment do |t|   
    fail "can't do this task in production" if ENV['RAILS_ENV'] == "production"
  end
  task :restore=>:check_environment do |t|
    $argv[:schools] = "sfu"    
    Rake::Task['init_app'].invoke;
    if $argv[:schools]
      Rake::Task['add_schools'].invoke; 
    end    
    Rake::Task['new_accounts'].invoke;
    Rake::Task['development:make_friends'].invoke;    
    Rake::Task['development:set_profile_pictures'].invoke if confirm("Set Profile Pictures? ");
    
  end
  desc "make everybody friends with everybody"
  task :make_friends=>:check_environment do |t|
    group = Student.find(:all)
    group.each do |s1|
      group.each do |s2|
        if s2 != s1
          p s1.full_name + " and " + s2.full_name
          StudentFriend.add_friendship(s1,s2)
        end
      end
    end
    
  end
  desc "set profile pictures"
  task :set_profile_pictures=>:check_environment do |t|
    path = prompt "Enter the directory for the profile images if you want profile images for the students "
    begin
      files = Dir.entries(path).select{|f| f != "." and f != ".."}.map{|f| File.expand_path(f,path)}
    rescue Exception=>e
       fail e.message
    end
    force = $argv[:force].pop == :true rescue false
    Student.find(:all).each do |student|         
          if not files.empty? and (not student.profile_image_set or force)
            p "setting profile for #{student.full_name}:"
            begin
              File.open(files.pop,"r") do |f|              
                student.profile_picture = f
              end
            rescue Exception=>e
                p e.message
            end
          elsif not files.empty?
            p "#{student.full_name} already has a profile picture"
          end  
    end
  end
end  
