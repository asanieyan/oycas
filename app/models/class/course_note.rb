class CourseNote < ActiveRecord::Base
#    has_one :file, :class_name=>'DocumentFile',:conditions=>:finder_sql =>''
    belongs_to :semester,:foreign_key=>'semester_id'
    belongs_to :course,:foreign_key=>'course_id'
    belongs_to :klass,:foreign_key=>'klass_id'
    belongs_to :owner , :class_name=>"Student", :foreign_key=>'owner_id'
    has_guid_field :uniq=>true     
    validates_presence_of :title    
    MaxAllowedFiles = 8
    MaxAllowedSize  = 30 #Mb
    def read_file
       return File.new(File.join(RAILS_ROOT,"/shared_docs/course_notes/#{self.guid}"),"rb")      
    end
    def before_destroy        
         FileUtils.rm(RAILS_ROOT + "/shared_docs/course_notes/#{self.guid}") rescue return
    end
    
    escape_once_and_truncate 'title','comment'
    validates_presence_of 'title'
    def is_anonymous?;self['anonymous'];end;
    def belongs_to? student
        return self.owner == student
    end
    def files= files
        begin       
          file = DocumentFile.archive(files,:name=>"#{self.guid}.zip",:filter_out=>%w(exe))
          raise DocumentFile::NoFile.new unless file
          raise DocumentFile::FileTooLarge.new if file.total_size > MaxAllowedSize
          note_dir = RAILS_ROOT + "/shared_docs/course_notes"
          FileUtils.mkdir_p(note_dir)        
          dest = File.join(note_dir,self.guid.to_s)
          File.open(dest,"wb") {|f| f.write(file.read)}              
#        rescue Exception=>e
#          p e.message                              
        end        
    end
end
