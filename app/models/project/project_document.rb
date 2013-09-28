class ProjectDocument < ActiveRecord::Base

  include ActionView::Helpers::TextHelper

  def store(document_field=nil, comment=nil, foldername=nil, project_id=nil)
    message = nil
    begin 

        filepath = "project_documents/#{project_id}"

        folderfilepath=nil
        if foldername != nil then
          folderfilepath = filepath+"/#{foldername}"
          if !FileTest.exists?("#{filepath}/#{foldername}") then
            message = {"project_error"=>"Specified Folder Not Found!"}
            raise "errors"
          end
        else
          foldername = "general"
          folderfilepath = filepath+"/general"
        end

        filename = document_field.original_filename.gsub(/^.*(\\|\/)/, '').gsub(/[^\w\.\-]/,'_')        

        #attempt to save info to database
        self.project_id = project_id
        self.comment = strip_tags(comment)
        self.folder = foldername
        self.filename = filename
        self.uploaded_on = Time.now.utc     

        self.save


        if self.valid? == false then
          message = self.errors
          raise "errors"
        end


        #check for existance of file and save, if possible.
        if !FileTest.exists?("#{folderfilepath}/#{filename}") then 
          File.open("#{folderfilepath}/#{filename}","wb") { |filehandle| filehandle.write(document_field.read) }
        else
          message = {"project_error"=>"File already exists!"}
          raise "errors"
        end

        return [true, {"project_error"=>"File upload successful",:type=>'success'}]

    rescue Exception => exc
      if exc.to_s != "errors" then
        message = {"project_error"=>exc.to_s}
      end
      return [false, message]
    end

  end


  def remove
    message = nil
    begin
      ProjectDocument.transaction do
        #if file exists, then delete
        filepath = "project_documents/#{project_id}/#{self.folder}"
        if FileTest.exists?("#{filepath}/#{self.filename}") then

          FileUtils.rm_f("#{filepath}/#{self.filename}")          

          if not FileTest.exists?("#{filepath}/#{self.filename}") then
            #remove database record
            self.destroy()
          else
            message = [false,"delete of file unsuccessful"]
            raise "errors"
          end

        else
          message = [false,"could not find specified file"]
          raise "errors"          
        end
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
