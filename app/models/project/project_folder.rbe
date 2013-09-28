class ProjectFolder < ActiveRecord::Base

  #has_many :project_files, :class_name=>"DocumentFile", :finder_sql=>'SELECT * FROM document_files WHERE document_guid = #{self.guid}'

  has_guid_field :uniq=>true  

 
  include ActionView::Helpers::TextHelper
  
  def files
    DocumentFile.find_by_sql "SELECT * FROM document_files WHERE document_guid = #{self.guid}"
  end

  def store(document_field=nil, comment=nil, project_id=nil)

    message = nil
    begin 

        filepath = "shared/project_documents/#{project_id}"

        folderfilepath=nil
        folderfilepath = filepath+"/#{self.folder}"
        if !FileTest.exists?("#{filepath}/#{self.folder}") then
          message = {"project_error"=>"Specified Folder Not Found!"}
          raise "errors"
        end

        filename = document_field.original_filename.gsub(/^.*(\\|\/)/, '').gsub(/[^\w\.\-]/,'_')        

        #attempt to save info to database

        DocumentFile.transaction do

         temp = DocumentFile.create(:id=>nil,:guid=>nil,:document_guid=>self.guid, :file_name=>filename, :created_on=>Time.now.utc, :file_comment=>strip_tags(comment)) rescue temp = nil

          if not temp.nil? then
            if temp.errors.length > 0 then 
              message = temp.errors #{"project_error","error in document file creation"}
              raise "errors"
              return
            end
          end



          #check for existance of file and save, if possible.
          if !FileTest.exists?("#{folderfilepath}/#{temp.file_name}") then 
            File.open("#{folderfilepath}/#{temp.file_name}","wb") { |filehandle| filehandle.write(document_field.read) }
          else
            message = {"project_error"=>"File already exists!"}
            raise "errors"
          end

        end

        return [true, {"project_error"=>"File upload successful",:type=>'success'}]

    rescue Exception => exc
      if exc.to_s != "errors" then
        message = {"project_error"=>exc.to_s}
      end
      return [false, message]
    end

  end


  def remove (filename)
    message = nil
    
    @file = DocumentFile.find(:first,:conditions=>["guid=?",filename]) rescue @file = nil
    filepath = "shared/project_documents/#{project_id}/#{self.folder}"    

    begin

      DocumentFile.transaction do
        #if FileTest.exists?("#{filepath}/#{@file.file_name}") then
          #remove database record
          @file.destroy()
        #else
          #message = [false,"delete of file unsuccessful"]
          #raise "errors"
        #end
      end

      if FileTest.exists?("#{filepath}/#{@file.file_name}") then
        FileUtils.rm_f("#{filepath}/#{@file.file_name}")          
      else
        #message = [false,"could not find specified file"]
        #raise "errors"          
      end

      message = [true,""]

      return message
      
    rescue Exception => exc
      if exc.to_s != "errors" then
          message = [false,exc.to_s]
      end
      return message
    end
  end


end
