/***************THUMBNAIL SELECTOR***************************/
var StudentThumbs = Class.create()
StudentThumbs.prototype = {
        initialize : function(div,lastPage) {
            this.miniProfilePlace = div  
            this.thumbs = new Array()  
            this.lastPage = lastPage
        },
        add :function(guid) {
             if ($(guid)) {                  

                    if ($(guid).down('img')) {                            
                            this.thumbs.push(guid)
                            Event.observe($(guid).down('img'),'click',
                                    this.thumbClicked.bindAsEventListener(this,$(guid).down('img')))
                    }
             }        
        },        
        thumbClicked : function(event,imgElement) {       
            imgParent = (imgElement.up())                        
            if (imgParent.hasClassName('thumb-selected'))
                redirect_to('/student/' + imgParent.id + '/profile')
            else {                 
                this.selectThumb(imgParent)             
            }
        },        
        selectThumb: function(profile) {                
                new Ajax.Updater(this.miniProfilePlace, 
                                '/student/' + profile.id + '/rate_profile',
                                {evalScripts:true,asynchronous:false}
                                
                ) 
                this.currentThumb().removeClassName('thumb-selected')
                profile.className = 'thumb thumb-selected'                
                    
        },
        currentThumb : function() {
             return selectedThumb = $(document.body).getElementsByClassName('thumb-selected')[0]                                   
        },
        next : function() {                        
            nextIndex = this.thumbs.indexOf(this.currentThumb().id) + 1
            nextProfile = ($(this.thumbs[nextIndex]))
            if (nextProfile == null) {
                    query = window.location.search.parseQuery()
                    query.page = (parseInt(query.page) || 1) + 1
                    if (query.page > this.lastPage)
                        query.page = 1
                        
                    window.location.search = $H(query).toQueryString()                    
                    
            }else {
                this.selectThumb(nextProfile)                
            }
        }   
}
