class DocumentFile
  SuppoertedImages = %w(png gif jpg)
  class FileTooLarge < Exception;end;
  class NoFile < Exception;end;

  def self.extract_extn filename
        File.extname(filename).sub('.','').downcase 
  end

  def self.cal_total_size tmpfiles
      return tmpfiles.inject(0) {|s,tmp| s += tmp.size}
  end
  def self.add_size_method object,size
      object.instance_eval <<-eof
          def total_size
              #{size.bytes / 1.megabyte}
          end       
      eof
  end
  def self.archive(tmpfiles,options={})      
      tmp = truncate(tmpfiles,options)
      return nil if tmp.empty?
      archive_f = Tempfile.new(options[:name])                
      add_size_method archive_f,cal_total_size(tmp)     
      archive_f.instance_eval <<-eof 
          def original_filename
              return '#{options[:name]}'
          end
          def path             
             File.join(Dir.tmpdir,"#{options[:name]}")
          end
          def read
            File.new(self.path,"rb").read
          end
      eof
      tmp_folder = File.join(Dir.tmpdir,rand(100000).to_s)
      FileUtils.mkdir_p tmp_folder      
      tmp.each {|t|           
          f = File.new(File.join(tmp_folder,t.original_filename),"w")
          f.write(t.read)
          f.close          
      }
      FileUtils.rm_f archive_f.path  rescue false      
      shell_command = "zip -jmr '#{archive_f.path}' #{tmp_folder}"      
#      p shell_command
      `#{shell_command}`
      FileUtils.rmdir tmp_folder rescue false
      return archive_f

  end
  def self.truncate(tmpfiles,options={})
      filter = options[:filter_in] || options[:filter_out]
      if filter 
        filter.map!{|f| f.downcase}
        filter_in  = options.delete(:filter_in) ? true : false
        
      end     
      max_size = options.delete(:max_size)
      tmp =  tmpfiles.map{|t| (t == nil || t.size == 0) ? nil : t}.compact
      tmp = tmp.select{|t| 
          ret_val = true
          if (filter) 
              ret_val = filter_in ? filter.include?(extract_extn(t.original_filename)) : !filter.include?(extract_extn(t.original_filename))
          end            
          ret_val = t.size <= max_size if max_size
          ret_val
      }                      
      return tmp      
  end
end
