class NoteFile < ActiveRecord::Base
  has_guid_field
  belongs_to :course_note
  def read
      note = self.course_note      
      root = Dir.pwd
      data = nil
      filename = nil
      begin        
        logger.debug Dir.pwd
        Dir.chdir("notes/#{note.guid}")
        if self.filename_occurance
            filename = self.file_name.sub("#{File.extname(self.file_name)}",
                  "(#{self.filename_occurance})#{File.extname(self.file_name)}")

        else
            filename = self.file_name
        end
        
        system %(7za e "#{note.archive_file}" "#{filename}")  
                                     
        data = (f = File.open(File.basename(filename),"rb")).read      
        f.close                            
      rescue Exception=>e
         
         logger.debug "Exception: " + e.message 
      end
      File.delete(File.basename(filename)) rescue nil
      Dir.chdir(root)     
      return data,{:filename=>filename}
  end
 
  
end
