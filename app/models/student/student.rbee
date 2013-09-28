class PopularityRate <  ActiveRecord::Base
    def self.rate rater,ratee,rate_value
        rate = self.find(:first,:conditions=>"rater_id = #{rater.id} AND ratee_id = #{ratee.id}")
        unless rate
          self.create(:rater_id=>rater.id,:ratee_id=>ratee.id,:rate_value=>rate_value)
          ratee.rating += rate_value
          ratee.votes += 1
        else
           if rate.created_on >= 1.month.ago           
             ratee.rating -= rate.rate_value
           else
             ratee.votes += 1
           end
           ratee.rating += rate_value
           rate.rate_value = rate_value
           rate.save;
        end
        begin
          ratee.avg_rate = (ratee.rating.to_f / ratee.votes.to_f).to_f
        rescue Exception=>e
#          p 'npw'
#          p e.message
        end
        ratee.save;        
    end
end
class StudentContactEmail < ActiveRecord::Base
    has_guid_field
    belongs_to :student
    def before_create
        self.visibility = student.profile_visibility
    end
    def address
      return contact_email
    end
end
class Student < ActiveRecord::Base
  include ActionView::Helpers::TextHelper  
  Profile_Sizes = %w(70x70 130x200 300x300)

  Student::MySelf = 0
  Student::Friend = 1
#  Student::ProjectMate = 2
  Student::ClassMate = 2
  Student::SchoolMate = 3
  Student::Everyone = 4
    
  VisibilityOptions = ["Only me (don't show)","Only my friends",  
                        "My friends and my classmates","Everybody in my school","Everyone"]  unless const_defined?("VisibilityOptions")                  
  VisibilityOptionsDescription = ["no one" , "your friends", 
                                "your friends and your classmates","everyone in your school","Everyone"]     unless const_defined?("VisibilityOptionsDescription") 
  PasswordLength = 6
  has_guid_field :unqi=>true
  
  #profile stuff 
  #these three methods also have cascading delete becuase if a dummy dstudent has never logged in
  #we can want to delete the profile school membership and email record that are created upon student creation
  #but for the ones that are logged in we suspend them
  has_one :profile, :class_name =>'StudentProfile',:dependent=>:destroy
  has_many :school_members,:dependent=>:delete_all
  has_many :emails, :class_name=>"StudentContactEmail" , :dependent=>:destroy do
            def unconfirmed 
                @unconfirmed_emails ||= find(:all,:conditions=>"confirmed IS NULL")
            end
            def confirmed
                @confirmed_emails ||=find(:all,:conditions=>"confirmed LIKE 'y'",:order=>'default_email DESC ')
            end
            def default 
                @default_email ||= find(:first,:conditions=>'confirmed LIKE "y" AND default_email LIKE "y" ')
            end            
  end
  has_many :violations,:class_name=>'ReportedItem',:foreign_key=>'student_id' do
        def stats
           unless @stats 
                @stats = find(:all,:select=>"count(*) as num, reason,item_type",
                              :joins=>'join item_reports on reported_items.id = report_id join report_reasons on reason_id = report_reasons.id join report_types on report_reasons.report_type_id = report_types.id',
                              :group=>'reason_id',:order=>'num DESC'                        
                        )                
                @stats = [@stats].flatten                
                class << @stats          
                    def each_violation_type 
                        self.group_by(&:item_type).each do |v,stats|
                            yield(v.to_s,stats)
                        end                                            
                    end                    
                    def num_reports
                         @sum ||= self.inject(0){|s,i| s += i.num.to_i;}
                    end
                end
            end 
            return @stats           
        end  
  end
  has_many :classifieds , :class_name=>'ClassifiedPost', :foreign_key=>'poster_id',:order=>'created_on DESC'
  has_many :recieved_friend_requests, :class_name=>'FriendRequest',:foreign_key=>'requestee_id', :order=>"created_on DESC"
  has_many :sent_friend_requests, :class_name=>'FriendRequest',:foreign_key=>'requester_id'
  
#  has_one  :default_email ,:class_name=>"StudentContactEmail",:conditions=>"default_email = 'y' AND confirmed LIKE 'y'"

  has_many :sent_messages , :class_name=>"IntranetMessage", :foreign_key=>'sender_id',:conditions=>'deleted_by_sender IS NULL',:order=>'created_on DESC'
  has_many :saved_messages, :class_name=>'IntranetMessage',  
          :finder_sql=> 'select m.*,r.is_read,r.id,r.folder from intranet_messages as m inner join intranet_message_registries as r on r.intranet_message_id = m.id where r.folder = "sm" AND r.reciever_id = #{id} ORDER BY created_on DESC'                                        
  has_many :inbox_messages, :class_name=>'IntranetMessage',  
          :finder_sql=> 'select m.*,r.is_read,r.id,r.folder from intranet_messages as m inner join intranet_message_registries as r on r.intranet_message_id = m.id where r.folder = "in" AND r.reciever_id = #{id} ORDER BY created_on DESC'
  #social stuff 
  has_many :friends, :through=>:student_friends, :source=>:student ,:extend=>StudentQuery
  has_many :student_friends, :foreign_key => 'friend_id'
  
  has_many :albums, :class_name=>'StudentPhotoAlbum'
  #academic stuff
  has_many :enrolled_semesters  ,:source=>:semester, :through=> :klass_enrollments, :select => "DISTINCT semesters.*"


  has_many :courses,:through=>:klass_enrollments  
  has_many :notes, :class_name=>"CourseNote",:foreign_key=>"owner_id" do 
      def not_anonymous
        @notes ||= find(:all,:conditions=>"anonymous IS NULL")
      end
    
  end
  
  has_and_belongs_to_many :networks, :finder_sql =>'SELECT DISTINCT networks.* FROM networks WHERE EXISTS( SELECT NULL FROM school_members JOIN schools ON school_members.school_id = schools.id WHERE school_members.student_id = #{self.id} AND schools.network_id = networks.id)'

  has_and_belongs_to_many :schools, :join_table=>'school_members', 
          :select=>"schools.*, school_members.default_school as is_primary",
          :conditions=>"school_members.confirmed LIKE 'y'",
          :order=>"school_members.default_school DESC"
#  has_and_belongs_to_many :projects, :join_table=>'project_members'
  
#  attr_accessible :gender,:birthdate,:birthdate_show_format,
#      :birthdate_show_format,:sexual_orientation,:sexual_orientation_visibility,
#      :relationship_status,:relationship_status_visibility

  composed_of :tz, :class_name => 'TZInfo::Timezone', 
              :mapping => %w(time_zone name)
  #validates_presence_of :first_name, :last_name, :message => "A piece of the full name is missing"
  #class methods 
  def before_create    
    self.sexual_orientation_visibility = relationship_status_visibility = self.profile_visibility =  self.current_course_visibility =  self.course_archive_visibility  =    self.desk_visibility = self.friend_visibility = Student::Everyone            
    self.login_time = self.logoff_time = Time.now.utc
    first_name.downcase!
    last_name.downcase!
    self.whole_name = first_name + " " + last_name 
    self.attributes.each do |k,v|
          if k =~ /notification/ 
            self[k] = :y
          end
    end
  end
  validates_inclusion_of :profile_visibility, :in=>1..VisibilityOptions.size
  validates_inclusion_of :current_course_visibility, :in=>0..VisibilityOptions.size,:message=>"woah! what are you then!??!!"
  validates_inclusion_of :course_archive_visibility, :in=>0..VisibilityOptions.size    
  validates_inclusion_of :desk_visibility, :in=>0..VisibilityOptions.size
  validates_inclusion_of :friend_visibility, :in=>0..VisibilityOptions.size
    
  def after_create
    StudentProfile.create :student_id => self.id      
  end
  def self.create_new(first_name,last_name,email,password,school,dummy=false)      
      self.transaction do
        SchoolMember.transaction do        
             student = Student.new(:username => email,
                             :first_name => first_name,
                             :last_name => last_name,                             
                             :time_zone=>school.time_zone
             )   
             student.rank = :dummy if dummy               
             student.password= password
              
             student.save

             SchoolMember.create :student_id=>student.id,:school_id=>school.id,
                                          :default_school=>'y',:registered_email=>email,:confirmed=>'y'
                                                                
             StudentContactEmail.create :student_id=>student.id,:contact_email=>email,
                                                 :confirmed => 'y', :default_email=>'y'
             return student
          end
       end                                
  end
  def self.find_by_guid(guid)
        self.find(:first,:conditions=>['guid = ? ', guid])
  end  
  def self.validate_name(name)
       first_name,last_name = name.split(" ",2)
       return first_name && last_name
#       first_name,last_name = self.name.split(" ",2)
#       first_name ||= ""
#       last_name ||= ""      
#       return false if first_name.size < 2 or last_name.size < 2
#       return true
  end
  def self.create_dummy(first_name,last_name,school,email=nil)
      unless email
        email = (first_name + last_name).gsub(/[ -.]/,'') + 
                    rand(10000).to_s + "@" + school.email_domain        
      end
      password = 'v3j7n1v3j7n1' 
      create_new(first_name,last_name,email,password,school,true)      
  end
  alias am? ==
  alias is? ==
  def password_eql?(password)
    require 'digest/md5'
    self['password'] ==  Digest::MD5.hexdigest(password)               
  end
  def password=string
    require 'digest/md5'
    self['password'] =  Digest::MD5.hexdigest(string)             
  end
  def is_pig?
    rank == :piggy
  end
  alias am_pig? is_pig?
  alias am_admin? is_pig?
  alias is_admin? is_pig?

  def is_suspended?;self.account_status==:suspended;end
#  def is_resetting_password?;self.account_status==:resetting_password;end
  def is_active?;self.account_status==:active;end
  def is_unactive?;self.account_status==:deactivated;end
  def is_suspended!
       self.account_status=:suspended
       self.account_status_change_date = Time.now.utc
       self.save     
  end
  def is_unsuspended!
       self.account_status=:active
       self.account_status_change_date = Time.now.utc
       self.save     
  end
  def to_my_time(time)
      return tz.utc_to_local(time)  
  end
  def logout_time;self['logoff_time'];end;
  alias time to_my_time
  def num_unread_messages
        @unread_count ||= IntranetMessageRegistry.find_by_sql("SELECT count(*) as count FROM intranet_message_registries WHERE reciever_id = #{self.id} AND is_read IS NULL")[0]['count'].to_i
  end
  def set_name!(name)
      f_name,l_name = name.split(" ",2)        
      self.first_name = f_name.downcase
      self.last_name = l_name.downcase
      self.whole_name = self.first_name + " " + self.last_name
      self.save
  end  
  def name part=nil
      case part
         when :first
          first_name.titlecase  
         when :last 
          last_name.titlecase
         when :full
          first_name.titlecase  + " " +  last_name.titlecase
         else
          [first_name.titlecase,last_name.titlecase]
      end      
  end
  def f_name;name(:first);end
  def l_name;name(:last);end
  def full_name;name(:full);end
    
  def klasses_at school       
       inst_var =  self.instance_variable_get "@klasses_for_#{school.id}"       
       
       if not inst_var
        
         semester = school.current_semester
         self.instance_variable_set "@klasses_for_#{school.id}", Klass.find_by_sql("SELECT k.*,c.subject as course_subject,c.number as course_number  from klasses as k INNER JOIN courses as c on c.id = k.course_id " +
                                       "WHERE semester_id = #{semester.id} AND " + 
                                       "EXISTS (" +
                                               "SELECT NULL FROM klass_enrollments ke " + 
                                              "WHERE ke.student_id = #{self.id} AND k.id = ke.klass_id )" )
               
         inst_var =  self.instance_variable_get "@klasses_for_#{school.id}" 
       end
       return inst_var
  end
  
  def remove_as_my_friend friend
        recs = []
        recs = StudentFriend.find(:all,
          :conditions=>"student_id IN (#{self.id},#{friend.id}) AND friend_id IN (#{self.id},#{friend.id})")
        StudentFriend.delete(recs.map{|r| r.id}) rescue true    
  end
  def get_image size
        size = size.to_s
        case size
            when 'small'
              prefix = 's'
            when 'medium'
              prefix = 'm'
            else
              prefix = 'l'
        end 
        #img = self.profile_image_set.to_s == "Y" ? self.guid.to_s : "_default"
        img = self.guid.to_s
        file_name = "/shared_images/student_profiles/" + prefix + img + ".jpg"
        if File.exists?(File.join(RAILS_ROOT,"public",file_name))
          return file_name
        else
          return "/images/#{prefix}anonymous.gif"
        end
  end
  def profile_image; get_image(:medium) ;end
  def rate_image; get_image(:large) ;end
  def thumb_image; get_image(:small); end
  def profile_picture= file     
      img_data = file.read 
      student_profile_dir = (File.join(RAILS_ROOT,"public/shared_images/student_profiles"))      
      FileUtils.mkdir_p(student_profile_dir) 
      flags = %w(s m l)
      begin
       Image.resize_to(img_data,Profile_Sizes).each_with_index do |img_data,i|
          File.open(File.join(student_profile_dir,"#{flags[i]}#{self.guid}.jpg"),"wb") do |f|
                f.write(img_data)
          end                         
       end
       self.profile_image_set = :y
       self.save           
      rescue Exception=>e
       
      end     
  end
  def default_contact_email=(email)
     raise unless email.confirmed     
     StudentContactEmail.transaction do      
       my_default_email = self.emails.default
       my_default_email.default_email = nil
       email.default_email = 'y'
       my_default_email.save;email.save;
     end
  end  

  def mood_status= status
        status ||= ""
        status = strip_tags status
        status.gsub!(/^\s+/,"")
        status.gsub!(/\s+$/,"")
        status.gsub!(/\s+/," ")
        status = truncate(status,100)
        status = nil if status.size == 0
        self['mood_status'] = status
        self.status_updated_on   = Time.now.utc
        self.save        
  end

  def relationship_status        
        self['relationship_status'] == "No Answer".intern ? nil : self['relationship_status']
  end 
  def birthdate
      return nil unless self['birthdate']
      case birthdate_show_format
        when :full
          self['birthdate'].strftime("%B")+ " " + self['birthdate'].day.ordinalize + ", " +  self['birthdate'].year.to_s
        else
          self['birthdate'].strftime("%B") + " " + self['birthdate'].day.ordinalize
       end
  end

  def gender;self['gender'].to_s;end

  def school
    @default_school ||= School.find_by_sql("select  schools.* from schools,school_members,students where students.id = #{id} and students.id = school_members.student_id and school_members.school_id = schools.id and school_members.default_school = 'Y';")[0]
    return @default_school

  end
  alias default_school school
  alias main_school school
  def exceed_max_reg_at school
    school.exceeds_max_reg self
  end

  def am_member_of? school;school.has_student? self;end
  alias is_member_of? am_member_of?
  
  def friend_request_to studentb
      @friend_requests  ||= {}
      unless  @friend_requests[studentb.id] 
           @friend_requests[studentb.id] = FriendRequest.find(:first,:conditions=>"requester_id = #{self.id} AND requestee_id = #{studentb.id}")        
      end
      @friend_requests[studentb.id] 
  end
  alias have_sent_friend_req_to friend_request_to
  
  def am_teammate_with? studentb
    relation_with(studentb) == ProjectMate
  end
  def am_classmate_with? studentb
    relation_with(studentb) == ClassMate
  end
  def am_friend_with? studentb
    relation_with(studentb) == Friend
  end
  alias am_friend_of? am_friend_with?

  def am_same_school_with? student
      relation_with(studentb) == SchoolMate
  end
  def can_see_sexual_orientation_of? studentb
        studentb.sexual_orientation_visibility >= self.relation_with(studentb)
  end
  #STUDENT WITH STUDENT METHODS

  def can_see_email_of? studentb,email 
      if can_see_profile? studentb 
         return email.visibiliy > self.relation_with(studentb)
      end
      return false #can't see profile can't see contact email
  end
  def can_see_profile_of? studentb
      return false if studentb.is_admin?
      studentb.profile_visibility >= self.relation_with(studentb)
  end
  def can_see_mood_status_of? studentb
      return studentb.status_option || can_see_profile_of?(studentb)      
  end
  def mood_status_set?  
      mood_status && mood_status.match(/\S/)
  end
  def can_see_current_classes_of? studentb
      return true if studentb.current_courses_option
      studentb.current_course_visibility >= self.relation_with(studentb)
  end
  def can_add_as_friend? studentb      
      return false if relation_with(studentb) <= Friend
      return true if studentb.add_friend_option
      return can_see_profile_of?(studentb)
  end
  def can_send_message_to? studentb     
#     return false if self == studentb or studentb.is_admin?
     return true if studentb.send_msg_option 
     return can_see_profile_of?(studentb)
  end
  def can_rate_popularity_of? studentb
     return true if studentb.rate_option
     return can_see_profile_of?(studentb)
  end
  def can_see_friends_of? studentb
       return true if studentb.friend_option
       studentb.friend_visibility  >= relation_with(studentb)
  end
  def can_see_relationship_status_of? studentb
       return true if studentb.relationship_status_option
       studentb.relationship_status_visibility  >= relation_with(studentb)    
  end  
  def can_see_birthdate_of? studentb
       return true if studentb.birthdate_option
       studentb.birthdate_visibility  >= relation_with(studentb)    
  end    
  def can_student_post_scrap? student
       (student.relation_with(self) <= Friend) and not student.is_pig?
  end 
  def can_post_scrap_to? studentb
      studentb.can_student_post_scrap?(self) 
  end 
  def can_student_see_scrap? student
      self.desk_visibility >= student.relation_with(self) 
  end
  def can_see_scrap_of? studentb
      studentb.can_student_see_scrap? self
  end
  def visibile_emails_to? student
        self.emails.confirmed.select{|e| 
            e.visibility >= student.relation_with(self)
        }  
  end
  def set_relationship_level_to_for studentb,level
      @relationships ||= {}
      @relationships[studentb.id] = level      
  end
  def dup_as level
      dup = duplicate
      set_relationship_level_to_for dup,level.to_i
      dup.set_relationship_level_to_for self,level.to_i
      return dup
  end  
  def duplicate
      dup = self.clone
      dup.id = self.id
      dup.profile = self.profile
      class << dup
          attr_accessor :schools,:friends
      end
      dup.schools = self.schools
      dup.friends = self.friends
      return dup      
  end
  def relation_with studentb
       # require 'student_friend.rb'
        raise RuntimeError, "can't find association with a " + studentb.class.to_s unless studentb.is_a? Student                  
        @relationships ||= {} 
        unless @relationships[studentb.id]                     
          @relationships[studentb.id] =  if self.id == studentb.id       
                                   MySelf
                              elsif StudentFriend.students_are_friends? self,studentb or self.is_admin?  
                                   Friend
                              elsif ProjectMember.students_are_teammates? self,studentb
                                   ProjectMate
                              elsif KlassEnrollment.students_are_classmates? self, studentb
                                   ClassMate
                              elsif SchoolMember.students_in_same_school? self,studentb
                                   SchoolMate
                              else
                                   Everyone                           
                              end    
           #set both ways relationship 
           #this line is very important is makes all the visility question two way
           #without and over head query
           studentb.set_relationship_level_to_for self,@relationships[studentb.id]
        end
        return @relationships[studentb.id]
  end
  def visible_album_counts studentb     
      v = self.relation_with(studentb) 
      StudentPhotoAlbum.count "student_id = #{self.id} and visibility >= #{v}"      
  end
  def visible_albums_to studentb
      v = self.relation_with(studentb) 
      StudentPhotoAlbum.find(:all,:conditions=>"student_id = #{self.id} and visibility >= #{v}")              
  end
  def any_profile_info_set? 
      has_general_info_set? or has_contact_info_set? or  has_personal_info_set?
  end
  def has_general_info_set?
      #need to check only one field to see if into is set
      return self['gender']
  end
  def has_contact_info_set?     
     #need to check only one field to see if into is set
     return self.profile['country']
  end
  def has_personal_info_set?
     return self.profile['religious_views']           
  end   
  def desc_for(index)
      VisibilityOptionsDescription[index]
  end
  def read_db_for attr  
    obj = self.class.find(self.id)
#    logger.debug  obj.send(attr.to_s)
    return obj.send(attr.to_s)
  end
#  for transition to id based visibility
#  composed_of :profile_visibility, :class_name=>'Visibility',
#        :mapping=>%w(profile_visibility index)        
  def timestamp_access! 
      self.last_access_time = Time.now.utc
      save;
  end
  def session_is_valid?(session)
    CACHE['student_' + id.to_s] == session.session_id
  end
  def get_dead_cgi
     if  CACHE['student_' + id.to_s]  
        @dead_cgi ||= ActionController::CgiRequest.new(CGI.new,ActionController::Base.session_options.merge(:session_id=>CACHE['student_' + id.to_s]))   
     end
     return @dead_cgi
  end
  def login_to session
      #find a dead session if there is one logout the student from it first
      if  dead_cgi = get_dead_cgi
        logout_from(dead_cgi.session)                  
      end    
      CACHE['student_' + id.to_s] = session.session_id 
      self.login_time = Time.now.utc        
      self.increment!('login_times')
      session['student'] = id             
  end
  def logout_from session
       CACHE['student_' + id.to_s] = nil       
       self.logoff_time = self.last_access_time || 1.second.ago       
       self.save      
       session.delete         
  end
  def validate        
#      self.birthdate_visibility = VisibilityOptions.size - 1 if birthdate_option
#      self.relationship_status_visibility = VisibilityOptions.size - 1 if relationship_status_option
#      self.current_course_visibility = VisibilityOptions.size - 1 if current_courses_option      
#      self.friend_visibility = VisibilityOptions.size - 1 if friend_option
#      return true
  end

  
  
end

