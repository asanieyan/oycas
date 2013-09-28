require 'yaml'  
require 'school'
class SchoolConfigurator
  attr_reader :config_dir,:config_file,:school_model,:config_hash,:config_environment

  def initialize school,environment = :development
    school_shortname = (school.is_a?(School) ? school.short_name : school).to_s      
    school_shortname.downcase!
    @config_dir = File.dirname(__FILE__) + "/../schools/#{school_shortname}"
    @config_file = load_config(school_shortname)
    @school_model = load_school_model(self)
    @config_hash = load_config_data(environment) 

  end
  def create_school
    raise "School already exists" if @school_model
    school_attributes = school_info.dup
    school_attributes.delete("network")
    school_attributes["network_id"] = get_school_network(self).id 
    logo = school_attributes.delete('logo')
    s = School.new school_attributes
    if s.save
       s.logo = logo                                      
    else
      raise "Can't Save School Because: " + s.errors.inspect
    end       
    @school_model  = s
    begin
      self.add_courses_to_school
      self.add_teachers_to_school
      self.semesters.each_with_index do |sem_config,i|
        attributes = {}
        season = Season.new
        sem_config.each do |k,v|
          attribute = k.match(/ /) ? k.sub(/ /,'_') : k
          season[attribute]= v          
        end
        season[:school_id] = @school_model.id
        season[:season_index] = i
        season.save        
      end
      #make sure the start and end months of the seasons for a school is consecutive and between 1 than 12
      months = []     
      @school_model.seasons.each do |season|        
        if season.start_month < season.end_month
          months << (season.start_month..season.end_month).to_a
        elsif 
          months << (season.end_month..12).to_a + (1..season.start_month).to_a
        end        
      end
      raise "The seasons are not right" unless months.flatten.uniq.sort ==(1..12).to_a
      update_school_semesters
    rescue Exception=>e
      p e.message
      p "RollBack"
      self.school_model.destroy
    end
  end

  def load_config_data environment = :development
    school_shortname = school_info['shortname'] 
    hash = {}
    Dir.foreach(@config_dir) do |file|
      file_with_dir =  @config_dir + "/" + file              
        if file =~ /#{school_shortname}_teachers_\d+\.yml/          
          yml = YAML::load_file(file_with_dir)          
          hash[:teachers] ||= [] 
          teacher = (environment.to_s == "development" ? yml['teachers'][0..5] : yml['teachers'])
          hash[:teachers] << [file,teacher]
        elsif file =~ /#{school_shortname}_courses.yml/          
          yml = YAML::load_file(file_with_dir)
          hash[:courses] =  environment.to_s == "development" ? yml['courses'][0..0] : yml['courses']         
        elsif file =~ /#{school_shortname}\.gif/
          hash[:logo] = file_with_dir
        end        
      end   
      hash
  end
  def school_info
    @config_file['school']
  end
  def semesters
    @config_file['semesters']
  end
  def update_school_semesters
      @school_model.set_new_semester
  end
  def add_courses_to_school 
     #converts a hash of format     
     @config_hash[:courses].each do |subject|          
         p 'processing subject: ' +  subject.inspect
         _subject = CourseSubject.find_by_code_and_school_id subject[:code],@school_model.id                    
         unless _subject
              p 'creating subject'
             _subject = CourseSubject.create :school_id=>@school_model.id, :code=>subject[:code], :name=>subject[:name]                   
         else
#              p 'subject ' + subject
         end            
         subject[:courses].each do |course|
             p 'processing course ' + course.inspect
             unless Course.find(:first,:conditions=>"school_id = #{self.id} AND course_subject_id = #{_subject.id} AND number LIKE '#{course[:number]}'")               
                p 'creating course'
                _course = Course.create :subject=>course[:subject],:number=>course[:number],:description=>course[:description],:name=>course[:name],
                                           :credit=>(course[:credit] || "").to_f, :school_id=>@school_model.id,:course_subject_id=>_subject.id 
             else
                p 'course already exists'
             end                                       
         end
     end            
  end
  def add_teachers_to_school 
    (@config_hash[:teachers] || []).each do |file,teachers|
#    next unless  confirm("add teachers in the file " + file)
    teachers.each do |teacher|
        email = teacher[:email]
        first_name = (teacher[:first_name] || "").gsub(/^\s+/,'').gsub(/\s+$/,'')
        last_name = (teacher[:last_name] || "").gsub(/^\s+/,'').gsub(/\s+$/,'')
        photo = (teacher[:photo] || "").gsub(/^\s+/,'').gsub(/\s+$/,'')
        unless email
            email = "#{first_name.gsub(/\s+/,'')}_#{last_name.gsub(/\s+/,'')}".downcase
        end
        email.gsub(/^\s+/,'').gsub(/\s+$/,'')
        email = email + "@" + @school_model.domain if email !~ /@.*?/
        p "processing instructor '" + first_name + " " + last_name + "', '#{email}'"
        teacher = Instructor.find(:first,:conditions=>"school_id = #{@school_model.id} AND email_address LIKE '#{email}'")
        unless teacher
          p 'creating instructor'
          teacher = Instructor.create(:school_id=>@school_model.id,:email_address=>email,:first_name=>first_name,:last_name=>last_name) rescue nil
          SchoolStaff.add_entry @school_model.id,email,"Added through yaml file"
        else
          teacher.locked = :y;
          teacher.save;
          p 'found instructor'
        end          
        if photo.size >0 and teacher
            p "updating teacher photo with url: '#{photo}'" 
            teacher.set_profile_image_from_net(photo)           
        end
      end
    end  
  end  
  def load_config(school_shortname)     
       p "loading the #{school_shortname} yaml file"  
      config_file = YAML::load_file("#{@config_dir}/#{school_shortname}_config.yml")
      fail "incorrect config file" if !config_file or (config_file['school']['short_name'].to_s.downcase != short_name rescue false)    
      return config_file
  end
  def load_school_model(configurator)     
       network = get_school_network(configurator)
       fail "can't find a the network #{configurator.school_info['network']}" unless network 
       school = School.find(:first,:conditions=>"name LIKE '#{configurator.school_info['name']}' AND network_id=#{network.id}")  
  end
  private
  def get_school_network(configurator)
    Network.find_by_name(configurator.school_info["network"]) rescue nil
  end
end
