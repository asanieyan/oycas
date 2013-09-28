module ClassifiedsHelper
    include ActionView::Helpers::TagHelper
    def show_network_tabs
          no_ajax_tabs(@my_networks.map{|n| Tab.new(n.name.titlecase,{:network=>n.name})}) do |tab|
                          tab.url[:network] == params[:network]
          end    
    end    
    def bread_crumb options = {}
        category = options.delete(:category) || @category
        network = options.delete(:network) || @network    
        search_query = nil
        if (params[:title] || "").size > 0
            search_query = "Search Results for '#{escape_once(params[:title])}'"
        end   
        html = []
        html << link_to(network.title + " Schools " + " Classifieds","/classifieds/network/#{network.name}/browse", options.update(:network=>network.name))
        category.node.ancestors.each do |parent|
            html << link_to(parent.category.name,:action=>'postings',:network=>network.name,:category=>url_encode(parent.category.name))
            #link_to_postings_for(parent.category,:html=>options)
        end
        unless search_query
          html << "<strong> #{category.name} </strong>"
        else
          html << link_to_postings_for(category, :html=>options)
          html << "<strong> #{search_query} </strong>"
        end
        return html.join(" > ")
    end
    
    def url_for_category category, options={}

        options = {:network=>options[:network] || params[:network], :category=>url_encode(category.name)}.merge(options)
        return classified_category_url(options)              
    end
    def link_to_postings_for category,options={}
          options[:action] = 'postings'    
          html = options.delete(:html)  
          text = options.delete(:text) || category.name
          link_to(text,url_for_category(category,options),html)
    end
   
end
