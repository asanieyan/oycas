module Parser 
      #options passed in 
      #content to be parsed
      #body_tag
      #delete_tags
      #strip_tags
      #block_condition
      #remove
      #also needs a pattern for a block and other pattern for within a block          
      def initialize
          @debug = false;
          super
      end    
      def clean_up content,options={}
              tag = tag_attributes = ""
              if (whole_tag = options[:body_tag])                     
                    if whole_tag.is_a? String
                            whole_tag.delete! "<"
                            whole_tag.delete! ">"
                            whole_tag.sub!(/\w(\w|\d)+/) do |match|
                                tag = match
                                ""
                            end                            
                            tag_attributes = whole_tag
                            if @debug
                              puts "body tag extracted = '#{tag}'"
                              puts "body tag attributes = '#{tag_attributes}'"
                            end
                            
                    end     #pattern tag not supported yet           
              end
              if tag.length != 0                  
#                  tag = "body"                                                      
              content.sub(/<#{tag}#{tag_attributes}.*?>(.*?)<\/#{tag}>/m) do |match|
                    puts(/<#{tag}#{tag_attributes}.*?>(.*?)<\/#{tag}>/m).to_s if @debug
                    content = $1  if match
              end             
             content.gsub!(/\r+/m,"\n")
             content.gsub!(/\t+/m,"")
             content.gsub!(/\n+/m,"\n")
             content.gsub!(/ +/m," ")
             end 
             if options[:region]                
               content = content.match(/(#{options[:region]})/m).to_s 
             end
             content = strip_tags(content, options[:strip_tags]) if options[:strip_tags]             
             content = delete_tags(content,options[:delete_tags])  if options[:delete_tags]                                                      
            return content             
      end
      def __parse__ options={}
         raise Exception, "You must have a content" unless options[:content]
         raise Exception, "You must specify pattern" unless options[:pattern]
#         pattern=>[key]
#         pattern=>[{key=>value}]
#         pattern=>[{key=>[value1,value2,value3]}]
#         pattern[key=>value,key=>value]
#         pattern[key=>[value1,value2],key2=>[value1]]
         pattern = [options[:pattern]].flatten
         if pattern[0].is_a? Hash #can't do that for now I don't know why its not working
                                  #so always pass a block pattern then component pattern
              key, value = pattern[0].shift               
              key_str = key.to_s
              key_str.gsub!(/([^\\])\(/,'\1')
              key_str.gsub!(/([^\\])\)/,'\1')
              block_pattern =  Regexp.new(key_str)              
              pattern[0] = {key=>value}
         else
              block_pattern = pattern[0]         
              pattern.delete_at 0         
         end
         section_ptrns = pattern
         content = options[:content]
#         urls.each do |url|
             tmp_content = content
             content = clean_up content,options   
             num_matched = content.scan(block_pattern).size
             p 'trying the block pattern on the new body: ' + block_pattern.to_s if @debug
             p 'number of block found = ' + num_matched.to_s if @debug
             if num_matched == 0 and false 
              p 'no block found for the pattern: ' + block_pattern.to_s
              #p tmp_content.gsub(/\n/,'<br>')
              p "#################################"
              p content
              #raise
             end
             content.scan(block_pattern).each do |match|                    #the matched block                                                                                         
               block = [match].flatten.to_s               
               if options[:block_condition]
                    if options[:block_condition].is_a? Array
                        condition = options[:block_condition][0]
                        arg=options[:block_condition][1]
                    else
                        condition = options[:block_condition]
                        arg = ""
                    end                    
                    if arg.to_s == "not_match"      
#                       p condition 
#                       p block    
#                       p block.match(/#{condition}/)           
                       next if block.match(/#{condition}/)
                    else
                       next unless block.match(/#{condition}/)
                    end
               end               
               block_ref = String.new block                                            
               returned_elements = Hash.new
               section_ptrns.each do |hashed_pattern| #array of hashes with one element pattern=>elements                                       
                 hashed_pattern.each do |ptrn,subs_list| #sub list is the array of elements :link, :code, :subject_name ,etc
                      subs_list = [subs_list].flatten
                      p "trying pattern on block : '#{ptrn}'" if @debug
                      p block if @debug
                      block.sub!(ptrn) do |match|   #for each block try a pattern                                                                                    
                          subs_list.each do |element|
                           unless element == :ignore #no element substition just ignore
                                 gv = 1 + subs_list.index(element)                                        
                                 eval "returned_elements[:#{element}] = delete_tags($#{gv},:all)"
                           end
                          end 
                          ""                                                             
                      end
                  end                             
                end
              if @debug 
                puts "*********************************************parsed block *************************************************" 
                puts block_ref + "----------------------------END---------------------------------------"
                puts "----------------------------------------------------------------------------------" 
                returned_elements.each do |name,value|
                      puts "#{name} : #{value}"
                end
                puts "************************************************************************************************************"
              end
              yield returned_elements
             end   #block loop                
#          end  #url loop
      end  #def end
      def strip_tags html, tags
        tags.each do |tag|           
              html.gsub!(/<#{tag.to_s}.*?>.*?<\/#{tag.to_s}>/mi,"")
        end
        return html
      end
      def delete_tags content,tags
        if tags == :all                    
           content.gsub!(/<.*?>/,"")
           content.gsub!(/&nbps;/,' ')
        else
           tags.each do |tag|
               tag = tag.to_s
               content.gsub!(/<\/?#{tag}.*?>/i,"")
          end
       end   
       return content
      end      
end
class Browser
      require 'net/http'  
      require 'net/https' 
      require 'uri'       
      def initialize
          @debug = false;
          @http = 
          super
      end 
      def login options={}
      
      end

end
class GeneralParser
     include Parser  
     attr_accessor :debug   
     def initialize
        @debug = true
        @urls = Array.new        
     end
     def parse force_url, parse_options          
       raise Exception, "Needs at least one url" if @urls.length == 0 and not force_url                   
         if force_url
          urls = [force_url]
         else
          urls = [@urls].flatten
          @urls = Array.new
         end
         if @debug
            puts "parse options: " 
            parse_options.each {|key,value|
                puts "#{key}: #{value.inspect}"
            }           
         end           
         urls.each do |url|
        
           puts "trying: #{url}" if @debug           
           uri = URI.parse(url)           
           http = Net::HTTP.new(uri.host,uri.port) 
           http.use_ssl = true if uri.scheme == "https"
           http.start do |http|
                request = Net::HTTP::Get.new(uri.request_uri)
                request["User-Agent"]="Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.0.9) Gecko/20061206 Firefox/1.5.0.9"
                request["Accept"] = "text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5"
                response = http.request(request)
                puts response.code + ":" + response.message if @debug
#                request.each_header {|key,value| puts key + " = " + value}
                parse_options[:content] = response.body
                 begin
                __parse__(parse_options) do |elements|                  
                    if elements[:next_link]                                                                    
                        unless URI.parse(elements[:next_link]).host
                            #check it next link is relative
                            if(elements[:next_link] =~ /^\//)
                                elements[:next_link] = uri.scheme + "://" + uri.host + elements[:next_link]
                            else                                                                   
                                elements[:next_link] = URI.join(url,elements[:next_link]).to_s                                  
                            end
                        end
                        @urls << elements[:next_link]                          
                        puts "adding a next link: " +  elements[:next_link] if @debug
                    end
                    ([parse_options[:prepend_url]].flatten).each do |e|
                      if elements[e] 
                            if(elements[e] =~ /^\//)
                                elements[e] = uri.scheme + "://" + uri.host + elements[e]
                            else
                                url.sub!(/\/$/,'')
                                begin
                                  elements[e] = URI.join(url,elements[e]).to_s 
                                rescue
                                  elements[e] = url + "/" + elements[e]
                                end
                            end
                      end
                    end
                    analyze_block elements
                end
#                rescue Exception=>e
#                  p e.message          
                end                
            end

        end      
     end
     def analyze_block elements
          #empty function
     end     
end
