module ActionView::Helpers::TextHelpers

  def strip_tags(html, specific_tags=nil)
    return html if html.blank?

    if html.index("<")
      text = ""
      tokenizer = HTML::Tokenizer.new(html)
 
      if specific_tags != nil then

        return html if specific_tags.is_a?(Hash) == false
        
        if specific_tags.has_key? :only then 
  
          while token = tokenizer.next

            node = HTML::Node.parse(nil, 0, 0, token, false)

            if node.class == HTML::Tag then
              if specific_tags[:only].index(node.name) == nil then
                text << node.to_s
              end
            else
              text << node.to_s
            end

          end
          text
        elsif specific_tags.has_key? :except then


          while token = tokenizer.next

            node = HTML::Node.parse(nil, 0, 0, token, false)

            if node.class == HTML::Tag then
              if specific_tags[:except].index(node.name) != nil then
                text << node.to_s
              end
            else
              text << node.to_s
            end

          end
          text
        else
          html
        end

      else
        while token = tokenizer.next
          node = HTML::Node.parse(nil, 0, 0, token, false)
          # result is only the content of any Text nodes
          text << node.to_s if node.class == HTML::Text  
        end
      
        # strip any comments, and if they have a newline at the end (ie. line with
        # only a comment) strip that too
        text.gsub(/<!--(.*?)-->[\n]?/m, "") 
      end
    else
      html # already plain text
    end
  end

end