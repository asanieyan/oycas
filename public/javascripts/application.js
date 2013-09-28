Event.observe(window,'load',function(){
//   Event.observe(window,'unload',function(){
//			
//	
//   })
//   $$("").each(function(button){
//       //button.observe('mousedown',function(){this.addClassName('button-link-active')}.bind(button))       
//       //button.observe('mouseup',function(){this.removeClassName('button-link-active')}.bind(button))               
//    
//   })

})
/*************************************************************************************************/         
    window.scrollXY = function() {
              var scrOfX = 0, scrOfY = 0;
              if( typeof( window.pageYOffset ) == 'number' ) {
                //Netscape compliant              
                scrOfY = window.pageYOffset;
                scrOfX = window.pageXOffset;
              } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
                //DOM compliant
                scrOfY = document.body.scrollTop;
                scrOfX = document.body.scrollLeft;
              } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
                //IE6 standards compliant mode
                scrOfY = document.documentElement.scrollTop;
                scrOfX = document.documentElement.scrollLeft;
              }
              return [ scrOfX, scrOfY ];                
    }
    
    window.redirect_to = function(url_obj) {
            if (typeof(url_obj) == 'string')
                window.location = url_obj
             else if (url_obj) {
                url_hash = new Hash(url_obj)
                return
                v = url_hash.remove('controller','action','id')
                url = "/" + v[0] + "/" + v[1]
                if (v[3]) url += "/" + v[3];
                if (url_hash.values.length > 0)
                    url += "?" + url_hash.toQueryString()
                   
                window.location = url    
             }                     
    }
    window.redirectTo = window.redirect_to
    var MyUtils = {
        append: function(element1, element2){           
           element2 = $(document.createElement(element2))
           element1.appendChild(element2)
           return $(element2)
        },
		hideIfNotClickedOn : function(element,elements,hideCallBack) {
			if (!hideCallBack){
				hideCallBack = function() {
					
				}			
			}
			element = $(element)
			if (!elements || elements.length == 0)
				elements = [element]

			elements = [elements].flatten().map(function(e){
					return $(e)
			})				
			Event.observe(window,'click',function(event){				
				
				if (!elements.include(Event.element(event))){
					$(element).hide()
					hideCallBack.apply()
				}		
			})	
		}		
    } 
    Element.addMethods(MyUtils);       
//String.heredoc = function(commentFunction){	
//	s = s.replace(/function/, '');
//	s = s.replace(/\(/, '');
//	s = s.replace(/\)/, '');
//	s = s.replace(/\{/, '');
//	s = s.replace(/\}/, '', -1);
//	s = s.replace(/\//, '');
//	s = s.replace(/\*/, '');
//	s = s.replace(/\//, '', -1);
//	s = s.replace(/\*/, '', -1);	
//}
/************************************************************************************************/
//var CustomSelectOption = Class.create();
//var CustomSelectTag = Class.create();
//CustomSelectTag.prototype = {
//	initialize : function(options,onchange)	{
//		this.html = ""
//		selectTagID = Math.floor(Math.random() * 10000);
//		selectedTextID = selectTagID + 1;
//		optionBoxID = selectedTextID + 1;		
//        this.html= "<table id='#{select_box_id}' class='custome-select-box top-v-align' cellspacing=0 cellpadding=0> \
//                  	  <tr> \
//	                      <td id='#{selectTagID}'> \
//	                          	<a href='#'> hey </a>				   \
//	                      </td>					   \
//	                      <td style='text-align:right;'> \
//	                        <a href='#' onclick='$(\"#{selectedTextID}\").toggle()'> <img src='/images/custom_select_arrow.gif' /> \
//	                       </td> \
//                   	   </tr> \
//                       <tr> \
//                      		<td colspan=2> "		
//	}	
//}
/************************************************************************************************/

var Flexer = Class.create()
Flexer.prototype = {
	initialize : function(id,options){
		this.flex = $(id);
		this.flex_content = $(id+"_in");
		this.options = Object.extend({                        
			 forceOpen : false,
			 onOpen  : function(){
                
             },
             onClose : function(){
               
             }
        },options || {})
		if (this.flex && this.flex_content){
			Event.observe(this.flex,'click',this.toggle.bind(this))
			this.flex.style.cursor = 'pointer'
			if (document.cookie.include(this.flex.id + '=close')){
				new Insertion.Top(this.flex,"<img id='" + this.flex.id +"_tri' src='/images/tri_close.gif' style='margin-right:5px'/>")				;
				this.flex_triangle = $(this.flex.id + '_tri');
				this.close();
			}else {
				new Insertion.Top(this.flex,"<img id='" + this.flex.id +"_tri' src='/images/tri_open.gif' style='margin-right:5px'/>")	;			
				this.flex_triangle = $(this.flex.id + '_tri');
			}			
		}
	},
	okToGo : function(){
		return this.flex && this.flex_content;
	},
	toggle : function() {
		if (this.flex_content.visible())
			this.close();
		else	
			this.open();
	},
	close : function(){
		
		if (!this.okToGo() || this.options.forceOpen){
			return;
		}
		this.flex_triangle.src = '/images/tri_close.gif';
		this.flex_content.hide();
		this.flex.addClassName('flex-close')  ;                  
	    this.options.onClose.apply()  ;                                                                           
	    document.cookie=this.flex.id+"=close";
	},
	open : function(){
		if (!this.okToGo()){
			return;
		}	
		this.flex_triangle.src = '/images/tri_open.gif'	
		new Effect.BlindDown(this.flex_content)
		this.flex.removeClassName('flex-close') ;                   
	    this.options.onOpen.apply()   ;                                                                          
	    document.cookie=this.flex.id+"=";
	}
}
var Flex = {
        toggle : function(flex,flexIn,options) {
               try {

                   options = Object.extend({                        
                        onOpen  : function(){
                            
                        },
                        onClose : function(){
                           
                        }
                   },options || {})
                   
                   flex = $(flex)
                   if (flexIn == null) {
                        flexIn = flex.id + "-in"
                      
                   }
                   if ($(flexIn).visible()) {                     
                     $(flexIn).hide()
                     $(flex).addClassName('flex-close')   
                   
                     options.onClose.apply()                                                                             
                     isClose = true
                     document.cookie=flex.id+"=close"
                    
                   }else {
                     options.onOpen.apply() 
                     $(flexIn).show()                     
                     $(flex).removeClassName('flex-close')
                     document.cookie=flex.id+"="                     
                     isClose = false
                   }
                 
                  qstr = $H({ 'box' : $(flex).id, 'close' : isClose }).toQueryString()

                  new Ajax.Request('/my/set_flex?' + qstr)
                  
              }
              catch(e){
              
             
              }
        }        
}    
/************************************************************************************************/
var JMenu = Class.create()
JMenu.prototype = {
        initialize : function(menuItemsSelector,hoverClass,activeClass,subMenuItemSelector,subMenuHover,subMenuActive) {
              this.menuItemsSelector = menuItemsSelector;
              this.hoverClass = hoverClass;
              this.activeClass = activeClass;              
            
              $$(menuItemsSelector).each(function(e){
                 //$(e).down("A").onclick = function(){return false}
                 e.style.cursor = 'pointer';
                 
                 Event.observe(e,'mouseover',function(){
                        e.addClassName(hoverClass)
                 
                 })
                 Event.observe(e,'mouseout',function(){
                        e.removeClassName(hoverClass)
                 
                 }) 
                 if (Prototype.Browser.IE)
                     this.observeMenuItem(e,this.menuItemClicked.bindAsEventListener(this,e))//takes care of turning on and of the menu item regardless whether it has submenu or not  
                 if ( e.readAttribute("submenu") && 
                      $(e.readAttribute("submenu"))
                     ){                                               
                       s = $(e.readAttribute("submenu"))                                           
                       s.hide()                      
                       s = SubmenuCache.add(s,this)
                       
                       s.addParent(e)
                       
                       s.addCSS(subMenuItemSelector,subMenuHover,subMenuActive)
                       
                       this.observeMenuItem(e,function(){SubmenuCache.refresh();this.activate()}.bind(s))
                 }
                 if (!Prototype.Browser.IE) 
                        this.observeMenuItem(e,this.menuItemClicked.bindAsEventListener(this,e))//takes care of turning on and of the menu item regardless whether it has submenu or not                                         
                
            }.bind(this));           
        },
        observeMenuItem  : function(elm,handler){             
             [elm].flatten().each(function(el){
                   Event.observe(el,'click',function(){                        
                        handler()
                   }.bind(this))                          
             }.bind(this))                  
        },        
        menuItemClicked : function(event,e) {                                                                                       s               
               if (groupID = e.readAttribute("group"))   {                                   
                    sel = this.menuItemsSelector + "[group='"+ groupID+"']"
                                        
                    $$(sel).each(function(groupE){
                        
                        groupE.addClassName(this.activeClass);
                    }.bind(this));
                }else                           
                    e.addClassName(this.activeClass);
                
                insideLink = $(e).down("A");
                insideLink.focus();                               
                if(insideLink.readAttribute('href') == "#" 
                        || insideLink.readAttribute('href') == "" ){ 
                     if (!insideLink.onclick){
                         insideLink.onclick = function(){return false}                             
                     }
                }else {
                    //e.removeClassName(this.activeClass);
                    window.location = insideLink
                }                    
                
         },      
        deactivateMenu : function(e) {
            elements = [e].flatten();      
            sameGroupElements = elements.inject([],function(tmpArray,e){                
                Try.these(function(){
                    groupID = e.readAttribute("group")
                })                
                if (groupID) {                                                          
                    sel = this.menuItemsSelector + "[group='"+ groupID+"']"  
                    if ($$(sel).length > 0){
                        tmpArray.push($$(sel))
                    }                    
                 }                                 
                 return tmpArray              
            }.bind(this)) 
            sameGroupElements = sameGroupElements.flatten().uniq()          
            sameGroupElements.invoke("removeClassName",this.activeClass)
        }
}
var SubmenuCache =  {
     submenuCache : [],
     refresh : function() {
        this.submenuCache.invoke("deactivate")     
     },
     add : function(submenuElement,jmenu){
        subm = this.submenuCache.find(function(sub){
           if (sub.element == $(submenuElement))
                return true;
        });
                
        if (subm) 
            return subm;           
        
        newSubMenu = new Submenu(submenuElement,jmenu.deactivateMenu.bind(jmenu)) ;   
        this.submenuCache.push(newSubMenu);
        return newSubMenu;
    }
}
var Submenu = Class.create();

Submenu.prototype = {
    parents : [], 
    submenuItems : [],       
    initialize : function(submenu,deactivateParent,submenuCache) {
        
        this.element = $(submenu);
        this.element.style.position = 'absolute';
        this.element.hide();   
        this.deactivateParentFunction = deactivateParent;      
        this.closer = this.closeHandler.bindAsEventListener(this)
    },
    addParent : function(parent){
        if (!this.parents.include(parent)){
            this.parents.push(parent);
            parent.descendants().each(function(e){
                this.parents.push(e);
            }.bind(this));
        }                   
        return this;
    },  
    addCSS : function(subMenuItemSelector,hoverClass,activeClass){
      
        if (this.submenuItems.length > 0)
            return        
        this.submenuItems = this.element.getElementsBySelector(subMenuItemSelector)
          
        this.submenuItems.each(function(e){                 
                                          
               e.style.cursor = 'pointer';			  
               Event.observe(e,'click',function(event){
			   		e = $(e)
                    e.down("A").focus();
                    e.removeClassName(hoverClass);
                    e.removeClassName(activeClass);
                    
                    window.location = e.down("A");
                    this.deactivate();                    
              }.bind(this));                              
               Event.observe(e,'mouseover',function(){                   
                    e.addClassName(hoverClass);
                    
               }.bind(this));
                              
               e.observe('mouseout',function(){                    
                    e.removeClassName(hoverClass);
               }.bind(this));
                
        }.bind(this))

        return this;
    },
    eq : function(submenu) {
        return this.element == submenu.element
    },
    isActive : function(){
        return this.element.visible();
    },
    activate : function(){   
        //this.cache.submenuCache.invoke("deactivate") 
        this.element.show(); 
        Event.observe(document.body,'click',this.closer) 
    },
    closeHandler : function(event) {                  
           clickElement = Event.element(event)               
           if (clickElement != this.element 
                && !this.parents.include(clickElement)) {                   
                this.deactivate() 
           }
    },
    deactivate : function() {
       
        Event.stopObserving(document.body,'click',this.closer)
        this.element.hide()           
        this.deactivateParentFunction(this.parents);
    }
}


/************************************************************************************************/
var Tabs = Class.create()
Tabs.prototype = {
	initialize : function(ulElement) {
		this.ulElement = $(ulElement)
		this.tabClickhandler = this.tabClicked.bindAsEventListener(this)
		this.liElements = this.ulElement.immediateDescendants()		
		this.liElements.each(function(li){
			  if (li.readAttribute("selected") == "true")	{
					this.selectedTab = li
			  }
			  this.makeTab(li)			  
		}.bind(this))
		if (!this.selectedTab) {
			this.selectedTab = this.liElements.first()
		}
		this.makeTabCurrent(this.selectedTab)
		
	},
	tabClicked : function(event) {
		li = Event.findElement(event, 'LI');
		if (li){
			Event.stopObserving(li,'click',this.tabClickhandler)
			this.makeTabCurrent(li)			
		}
	},
	makeTabCurrent : function(li) {
		if (li != this.selectedTab) {
			this.makeTab(this.selectedTab)	
		}
		if (li.readAttribute("xhr") == "true"){	
			tab_updatable = this.ulElement.parentNode.next("div")
			url = li.readAttribute("url")
			new Ajax.Updater(tab_updatable,url,{asynchronous:false})				
		}
		li.update("<span>" + li.readAttribute("name") + "</span>")
		li.removeClassName("off")
		li.addClassName("on")			
		this.selectedTab = li	
		
	},
	makeTab : function(li) {
		li.update("")
		a = li.append("a")
		a.update(li.readAttribute("name"))
		a.href = li.readAttribute("url")
		if (li.readAttribute("xhr") == "true"){													
			a.onclick = function(){return false;}			
			Event.observe(li,'click',this.tabClickhandler)
		}
		li.removeClassName("on")
		li.addClassName("off")	
	}	
}
var Tab = Class.create()
Tab.prototype = {
        name: null, //the name of the tab
        domElement:null, //the dom element that represent this tab in the dom page 
        contentURL: null, //the url from which the tab request its content
        
        initialize : function(name,url,xhr) {
                    this.name = name;
                    this.contentURL = url;   
                    this.useXHR = xhr
                    if (this.useXHR == null)
                        this.useXHR = true
                        
                       
        }
}
var TabSet = Class.create()
//contains a group of tabs 
//also manages the tab on the click 
TabSet.prototype = {
        tabs: new Array(), //an array of tabs 
        domTabBox: null,
        currentTab: null,
        updateArea: null,
        tabsetID: null,
        initialize : function(tabbleDiv) {                
                tabbleDiv = $(tabbleDiv)                
                if (tabbleDiv == null)
                    return
                headerID = tabbleDiv.id+"-tabs"
                updateID = tabbleDiv.id+"-updatable"
                new Insertion.Top(tabbleDiv,"<div class='header'><ul id='" + headerID + "'></ul></div>" )
                new Insertion.Bottom(tabbleDiv,"<div class='tab-updatable' style='clear:left;width:100%' id='" + updateID + "'> </div>" )              
                
                this.domTabBox = $(headerID)   
                this.updateArea = $(updateID)  
                this.updateArea.addClassName('tab-updateable-area')                                          
                this.tabsetID = tabbleDiv.id
        }, 
        setTabs : function(tabs,currentTab) {
                if (currentTab == 'undefined' || currentTab == null) 
                        this.currentTab = tabs[0]
                else
                        this.currentTab = currentTab

                tabs.each(function(tab){
                    this.addTab(tab)
                
                }.bind(this))                            
        },       
        addTab : function(tab,options) {
             if (tab instanceof Tab && tab.name != 'undefined' && tab.url != 'undefined') {
                //options.position the position to place the tab must be between 0 to current number of tabs
                //options.wait if true then the tabs is added after the content is loaded                
                options = options || {}                
                if (options.position < 0 || options.position >= this.tabs.length ) {
                    position = null                              
                }
                li = this.domTabBox.append("li")                                                                    
                tab.domElement = li
                if (tab == this.currentTab) 
                {//add the first tab as the current tab
                      this.setCurrentTab(tab)                                     
//                    this.clickable(tab,false)                    
//                    this.updateArea.update("&nbsp;" + tab.initialContent)
                }else {                      
                    this.clickable(tab,true)                                   
                }
                this.tabs.push(tab)                               
             }
        },
        gotoTab : function(name) {
            foundTab = null;
            this.tabs.each(function(tab){
                   if (name == tab.name)     {
                        foundTab = tab;
                        throw $break;
                   }            
            });
            if (foundTab){
                this.setCurrentTab(foundTab)                
            }
            
        },
        setCurrentTab :function(event,tab) {
               if (event instanceof Tab) {
                    tab = event
               }
               var tabset = this
               if (tab.useXHR) {
               new Ajax.Request(tab.contentURL,{
                    asynchronous: false,
                    parameters: {
                        
                        tabset: tabset.tabsetID,
                        tab: tab.name                        
                        
                    },
                    onFailure: function(transport){
                            Message.show({'general-system-messages' : ["Server error. Please try again.",transport.responseText]})
                            tabset.updateArea.update("&nbsp;")
                    },
                    onSuccess: function(transport) {         
                                    tabset.updateArea.update(transport.responseText)
                                    tabset.clickable(tabset.currentTab,true)
                                    tabset.clickable(tab,false)
                                    tabset.currentTab = tab

                               }
                    })
               }else {
                   
                    redirect_to(tab.contentURL)
               
               }
                             
        },
        clickable :function(tab,clickable) {
                if (tab.domElement == 'undefined')
                    throw "Tab doesn't have element"               
                tab.domElement.update("")
                tab.domElement.removeClassName("on")                
                tab.domElement.removeClassName("off")                
                if (clickable) {                                        
                    tab.domElement.addClassName("off")                   
                    a = tab.domElement.append("a")
                    a.href = "#"                    
                    a.update(tab.name) 
                    Event.observe(a,'click',this.setCurrentTab.bindAsEventListener(this,tab)) 
                    a.onclick = function() {
                            return false;
                    }        
                }else {
                    tab.domElement.addClassName("on")
                    tab.domElement.update("<span>" + tab.name + "</span>")
                }
        },        
  
                
        removeTab : function(name) {
                
        
        }
}

/*************************************************************************************************/    
var Canvas =  Class.create()    
Canvas.prototype = {                          
              initialize : function(){                        
                    this.canvasElements = new Array()
              },                  
              add : function(element) {                   
                     tmpElement =  $(document.createElement(element))        
                     tmpElement.style.position = 'absolute'
                     document.body.appendChild(tmpElement)                         
                     this.canvasElements.push(tmpElement)                      
                     return tmpElement
              
              },
              destroy : function(remove){                 
                  this.canvasElements.each(function(element){                                               
                        element.hide()
                       
                        if (remove)
                            element.remove()
                            
                  });                
              }            
}       
//    var Pop = Class.create();
Pop = {
    isOpen : false,
	canvas : null,
    setOptions : function(options) {
            return Object.extend({
            title: "&nbsp;",
            width: "400px",
            height: "100px",
            url: null,
            fixed:false,
            removeCanvas:false,
            onclose:null,            
            onpop:null            
        },options || {});    
    },     
    IESelectBoxFix : function(action) {       
       if (Prototype.Browser.IE && !navigator.userAgent.include('7.0'))     {
            if (action == "popup"){               
               this.selectElements = [];               
               $$("select").each(function(e){                       
                    if ($(e).style.visibility != "hidden")
                    {   
                        $(e).style.visibility = "hidden"
                        this.selectElements.push(e);
                    }               
               }.bind(this));               
            }else{
                this.selectElements.each(function(e){
                       
                         $(e).style.visibility = "visible"
                })
                this.selectElements = [];
            }
        }
    },
    up : function(WinOptions,AjaxOptions) {              
         SubmenuCache.refresh();//if a submenu is open and a popup is there it screws up the view for some reason
         this.options = this.setOptions(WinOptions)  
         this.IESelectBoxFix("popup") //for IE browsers   
         container = this.drawGraphics()  
         this.container = container
         onpopCall = eval(this.options.onpop)
         if(typeof(onpopCall) == 'function') {           
              retVal = onpopCall.call(container) 
              if(retVal == false) {                               
                this.close()
                return false
              }
         } 
         AjaxOptions = Object.extend({
            onSuccess : function(request) {                                
                container.update(request.responseText);
                //Pop.titleBox.style.width = 30
            }, 
            on300 : function(request) {                
                container.update("<div class='status-box title-div'>Please wait...</div>")
            
            },
            on302 : function(request) {                
                container.update("<div class='status-box title-div'>Please wait...</div>")
            
            },
            onFailure : function(request) {                  
                container.update("<div class='status-box title-div'>Problem connecting to the server. Please try again.</div>")     
            }                    
         },AjaxOptions || {});    
         this.isOpen = true;       
         if (this.options.url != null) {            
             new Ajax.Request(this.options.url,AjaxOptions);                                 
         }else
            return container                                                                 
    },
    drawGraphics : function(){
         
         this.canvas = new Canvas();
         canvas = this.canvas   ;          
				
         shield = canvas.add("div");           
         shield.update("&nbsp;")
         shield.addClassName('popup-shield')        
         shield.style.height =  document.body.scrollHeight         
         
         this.popupWindow = canvas.add("div"); 
         this.popupWindow.addClassName("ie-png-shade-fix-wrapper"); //work around for ie can't add transulent bc image if the div is position absolute
         this.popupWindow.style.top = window.scrollXY()[1] + 67;                  
         
         popDialogBox = this.popupWindow.append("div"); 
         popDialogBox.addClassName("popup");         
         popDialogBox.style.width = this.options.width;

         //since when the pop close it actually hides for some reason that 
         //i can't remeber we must generate a random id for elements that use id to work
         titleID = 'title-box' + Math.floor((Math.random() * 1000000000))
         contentID =  'content-box' + Math.floor((Math.random() * 1000000000))        
         popDialogBox.update("<table cellspacing=0 style='width:100%' cellpadding=0 ><tr><td id='" + titleID + "'><td></tr><tr><td id='"+ contentID +"'></td></tr></table>")                   
//         popDialogBox.update("<div id='" + titleID + "'></div><div id='"+ contentID +"'></div>")                   
         this.titleBox = $(titleID) 
         this.titleBox.style.position = 'relative' 
         if (!Prototype.Browser.IE)
            new Insertion.Top(this.titleBox,'<b class="rtop"><b class="r1"></b> <b class="r2"></b> <b class="r3"></b> <b class="r4"></b></b>');                                                
         popTitleBox = this.titleBox.append("div"); 
         if ((this.options.title || "").blank()){ this.options.title = "&nbsp;";}           
         popTitleBox.update(this.options.title);         
         popTitleBox.addClassName("popup-title");
         new Insertion.Top(popTitleBox,"<input type='button' onclick='Pop.close()' class='button-link close-button' style='float:right;padding:0' value='X'>")                  
         //closeButton = popTitleBox.append("img") 
         //closeButton.src = 'http://www.tnellen.com/pics/x-2.gif'                                                         
         //Event.observe(closeButton,'click',this.close.bindAsEventListener(this))
         if (!this.options.fixed) {
             new Draggable(this.popupWindow,{handle:this.titleBox});
             Event.observe(this.titleBox,'mousedown',function(){
                 document.body.style.cursor = 'move'             
             }.bind(this))
             Event.observe(document.body,'mouseup',function(){
                 document.body.style.cursor = 'default'             
             }.bind(this))
         }
         popContentBox = $(contentID)        
         popContentBox.addClassName("popup-container"); 
         popContentBox.update("<div style='text-align:center;padding-top:40px'> <img  src='http://pics.ebaystatic.com/aw/pics/express/images/imgLoading.gif' /> </div>");            

         
         return popContentBox;     
    },        
    close : function(event) {                  
//        Effect.Fade(this.popupWindow,{duration:0.2})
        document.body.style.cursor = 'default' 
        this.IESelectBoxFix("close")
        this.canvas.destroy(this.options.removeCanvas)
        try {            
            callback = eval(this.options.onclose)
            
            if (typeof(callback) == 'function')
                callback.call()
          
        }  catch(e) {
//            alert(e)
        }
		this.isOpen = false;         
    
    }
}       
function ErrorAlert() {
    CAlert({message:"<div class='status-box title-div'>Problem connecting to the server. Please try again.</div>"})
}
function CAlert(options) {
    options = Object.extend(options || {},
                {alertOnly:true})
    Confirm(options)
}
function Confirm(options) {         
        options = Object.extend({
                title : "",
                message: "",
                form: null,
                onconfirm:null,
                onpop: null,
                onclose: null,              
                url: null,
                alertOnly:false
                                        
        },options || {})
        
        try {
            options.form = $(options.form)            
        }catch(e) {
           
        }    
        container = Pop.up({onpop:options.onpop,onclose:options.onclose,'title':options.title,width:'500px',height:'100px'})        
        if (container == false) {           
            return
        }
        if(typeof(options.message) == "function")
            container.update(options.message.call())
        else{
            
           container.update(options.message)
        }
        bottomDiv = container.append("div")
        bottomDiv.style.marginTop = '20px'
        bottomDiv.style.textAlign = 'right'
        bottomDiv.style.marginRight = '20px'
        if (!options.form) {
            form = bottomDiv.append("form")
            form.action = options.url
            form.method = "POST"                                                   
            options.form = form
        }
        /*
        Event.observe(options.form,'onsubmit',function(){                        
             alert('d')
             callback = eval(options.form.onsubmit)
             if (typeof(callback) == 'function') {
                callback.call()
             }
         })*/
        cancel = bottomDiv.append("button")             
        if (options.alertOnly)
            cancel.appendChild(document.createTextNode('Ok'))
        else
            cancel.appendChild(document.createTextNode('Cancel'))
        cancel.addClassName("button-link")  
        cancel.style.marginRight = '20px'             
        Event.observe(cancel,'click',function(){Pop.close();})
        if (!options.alertOnly){
            ok = bottomDiv.append("button")
            ok.appendChild(document.createTextNode('Confirm'))      
            ok.addClassName("button-link") 
            Event.observe(ok,'click',function(){   
                if (options.onconfirm){
                    x = function() {                   
                        eval(options.onconfirm)
                    }
                    x()
                 }else{
                    options.form.submit();
                 }
            });
        }
 

}
    
/*************************************************************************************************/         

/***************************************************************************************/

var Message = {        
     flashMsgs: [],
     options : {
          type : "error",
          hide : false,
          block : null,
          position: 'after'   
     },  
	 showUpload : function(div) {
	 	$(div).hide();
		new Insertion.After($(div),"<div style='display:table' class='centered' id='progress'><img src='http://pics.ebaystatic.com/aw/pics/express/images/imgLoading.gif' /><span class='dark-bold-gray'>This might take a while specially during peak the hours. Please don't close the browser until the upload is done.</span></div>")		
	 },
     show: function(errorObjs,options)   {
        /*Reads the errorsObjs of the format
            "elementID" : "error1"[,"error2",...]
            revert all the elements in the histroy back to their previous no error state 
            for each of the valid elementID  
                keep a clone the element in histroy 
                change the color of error to red 
                add the error 
            run the javascript block of code
            that is if you want to do something after the errors are shown
        */                         

            if (typeof(options) == 'string' && options != 'null')
                 options = eval("(" + options + ")");
            else if (options == 'undefined' || options == null)
                 options = { }            
            type = options.type || this.options.type
            hide = options.hide || this.options.type
            position = options.position || this.options.position
            block = options.block
            
            if (type == 'success') {
                type = 'info'
                hide = true
            }
            if (typeof(errorObjs) == 'string')
                 errorObjs = errorObjs.evalJSON() //eval("(" + errorObjs + ")");                
            
            this.revert()
            for(element_id in errorObjs) {            
                    element = $(element_id)
                    if (element != null) {
                        //now get the div for the error message of this item
                       msgs = errorObjs[element_id]                      
                       
                       if (msgs.length == 0)        
                            continue;
                       else if (msgs.length == 1)
                            msgs =  msgs[0]
                       else if (typeof(msgs) == 'object'){
                            msgs = msgs.grep(/\S+/)
							if(msgs.length > 1)
						    	msgs = "<ul style='padding-left:2px'>" + msgs.map(function(msg){return "<li >" + msg + "</li>"}).join("") + "</ul>"
							else
								msgs =  msgs[0]
                       }
                       
                        divID = element_id + "-" + type                        
                        msgContainer = $(divID)
                        if (msgContainer == null) {

                                str = "<div id='"+divID+"' class='server-"+ type +"-message'></div>"
                                if (position == "after")
                                    new Insertion.After(element,str)  
                                else if (position == "bottom")
                                    new Insertion.Bottom(element,str)  
                                msgContainer = $(divID)                            
                        
                        }                         
                        this.flashMsgs.push(element)                            
                        msgContainer.update(msgs)
                        msgContainer.show()                        
                        if (hide == true || hide == 'true')  {                           
                            setTimeout("Effect.Fade('"+divID+"');",2000)                            
                        }                                                                 

                    }
                    

            }
            if (block != null){
                try{
                    eval(block)
                }catch(e) {}
             }
        
     },
     revert: function() {
        /*iterates through the flash array and return all the objects in their to
          their previous no error state*/
        this.flashMsgs.each(function(obj){
                Try.these( 
                        function() { 
                            obj.style.color = "black"
                            $(obj.id+"-error").remove()
                            
                        }                
                )
                        
        
        })
        this.flash = new Array()
     
     }

}
//*******************************************************************************************

//var SelectSearcher = Class.create()
var Select =  {     
        disable : function(){
        
            this.disabled = true;
        },
        enable : function(){
          this.disabled = false;
        },
        eachOption : function(element1,callback) {
           element1 = $(element1)
           for(i=0;i<element1.options.length;i++) {
               try {                                      

                    callback($(element1.options[i]),i)
               }catch(e){
                    
                    if (e != $break) throw e; 
                    else
                        break;              
               }
           }             
        }, 
        clearOptions : function(element1) {
            element1 = $(element1)
            element1.eachOption(function(option){
                    option.selected = false
                    
                
            })            
        },        
        setOptionByValue : function(element1,value){
                element1 = $(element1)
                element1.clearOptions();
                foundIndex = 0
                element1.eachOption(function(option,index){                        
                        if  (option.value == value) {
                            foundIndex = index
                            throw $break;    
                        }
                                                
                }) 
                element1.selectedIndex = foundIndex
        },
        selectedOption : function(element1) {
             element1 = $(element1)
             selectedOption = null
             element1.eachSelectedOption(function(option){
                    
                    selectedOption = option
                    throw $break;             
             })
             return selectedOption
        },
        eachSelectedOption : function(element1,callback) {
              element1 = $(element1)
              element1.eachOption(function(option){
                    
                    if (option.selected == true) {
                        callback(option)
                    }              
              })            
        }, 
        searchPreperation : function() {
        
        
        
        },
        searchByElimination : function(select,text){                
                select = $(select)
                select.show();
                select.clearOptions();
                select.eachOption(function(o){
                        $(o).show()                
                })                
                if (text.value.blank())
                    return
                   
                select.eachOption(function(option){                     
                     optVal = option.innerHTML                     
                     if (!optVal.toLowerCase().include(text.value.toLowerCase())){                       
                        $(option).hide();
                       
                     }
                })
                selectedOption = null
                select.eachOption(function(o){if(o.visible()){
                        o.selected=true;
                        selectedOption = o
                        throw $break;                         
                }})  
                if (!selectedOption && !Prototype.Browser.IE)  
                    select.hide();              
                Try.these(function(){
                        select.onchange.apply()
                })                                                  
                                                      
        },
        search : function(select,text) {                             
                targetOption = null
                select = $(select)
                select.clearOptions() 
                if (text.value.blank())
                    return
                select.eachOption(function(option){
                     optVal = option.innerHTML                     
                     if (optVal.toLowerCase().include(text.value.toLowerCase())){                                               
                        targetOption = option;
                        throw $break; 
                     }
                })
                if (targetOption) {
                    select.clearOptions()
                    targetOption.selected = true
                }         
                Try.these(function(){
                        select.onchange.apply()
                })
                
              
        }
}
Element.addMethods(Select)
var Link = {
    disableLink: function (e) {
        e.onclickHandler = e.onclick || function(){return true;};
        e.onclick = function() { return false};    
        e.addClassName('disabled-link');             
    },
    enableLink : function(e) {
        e.removeClassName('disabled-link');
        if (e.onclickHandler) {
               e.onclick = e.onclickHandler;             
        }
    }
}
Element.addMethods(Link)


//******************************************************************************
// CODE FOR VISIBILITY CONTROL ON CONTACT INFO PAGE IN PROFILE
//******************************************************************************
function updateProfileSample(checkbox) {
    try {
        id = checkbox.id.gsub(/mini\[(.*)\]/,"#{1}")
        e = $(id)
        if (checkbox.checked)
            e.show()
        else
            e.hide()
    }catch(e) {}


}
/***************************************************************************************/
// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//tab object

function switchContent(container1,container2) {
            var temp = $(container1).innerHTML
            $(container1).innerHTML = $(container2).innerHTML
            $(container2).innerHTML = temp
}
function toggleStuff(DOMID) {          

        if ($(DOMID).style.display == 'none') {
            display = 'block'
        }else {
            display = 'none'
        }
        $(DOMID).style.display = display

 }

function Tab (name, url) {
    //initialize
    this.name = name;
    this.url = url;
}

//tab pane object
function TabPane (myname, target, tabnames, taburls) {
    //initialize
    this.myname = myname;
    this.target = target;
    this.TabArray = new Array();
    for(var x=0; x<tabnames.length; x++) {
        this.TabArray.push(new Tab(tabnames[x], taburls[x]))
    }

    this.clicked = function (index) {
        var tempRequest = new Ajax.Updater(this.target,this.TabArray[index].url, {method: 'post'});
        this.update(index);
    }

    this.update = function (index) {
        //turn all of them off 
        for (var x=0; x<this.TabArray.length; x++){
            temp = document.getElementById(this.myname+x);
            temp.style.backgroundColor="ffffff";
            temp.innerHTML="<a href=\"javascript:void(0);\" onclick=\"eval('"+this.myname+".clicked("+x+")')\">"+this.TabArray[x].name+"</a>";
        }
        //set indexed one to active
        temp = document.getElementById(this.myname+index);
        temp.style.backgroundColor="00ffff";
        temp.innerHTML=this.TabArray[index].name;
    }

    this.draw = function () {
        for (var x=0; x<this.TabArray.length; x++){
            document.writeln("<div class=\"tabbutton\" id=\""+this.myname+x+"\"></div>");
        }
    }

}

//******************************************************************************
// CODE FOR VISIBILITY CONTROL ON CONTACT INFO PAGE IN PROFILE
//******************************************************************************
function changeSecMenuState(index, myvalue) {
	if (myvalue=='on') {
		document.getElementById("closeButton"+(index)).style.display='block';
		document.getElementById("selectionBox"+(index)).style.display='block';
	} else if (myvalue=='off') {
		document.getElementById("closeButton"+(index)).style.display='none';
		document.getElementById("selectionBox"+(index)).style.display='none';
	}
}

function securityupdate(index, myvalue) {

	for (x=1; x<6; x++) {
		
		if (x <= myvalue) {
            document.getElementById("img"+(index)+""+(x)).setAttribute('src','/images/securitycontrol/onstate.gif');
		} else {
			document.getElementById("img"+(index)+""+(x)).setAttribute('src','/images/securitycontrol/offstate.gif');
		}
	}
	
	if (myvalue == 5) {
    	document.getElementById("level"+(index)).innerHTML = "everyone";
    } else {
    	document.getElementById("level"+(index)).innerHTML = "level "+(myvalue);
    }
}

function createSecurityControl(index) {
new Control.Slider('handle'+index,'track'+index,{
	range:$R(0,5),
	sliderValue:$('security'+index).value,
        values:[0,1,2,3,4,5],
        onSlide:function(v){
		$('security'+index).value=v;
		securityupdate(index, v);
	}
        });
	securityupdate(index, $('security'+index).value);
}
//******************************************************************
//CODE FOR FORUM INTERFACE DIV showing/hiding
//******************************************************************
function forumStateToggle(index,target) {
    //set both to none
    document.getElementById("forumDeleteArea"+index).style.display="none";
    //set target to active
    if (target) {
        document.getElementById(target+""+index).style.display="block";
    }
}


//******************************************************************
//CODE FOR SCRAP INTERFACE DIV showing/hiding
//******************************************************************
function scrapStateToggle(index,target) {
    //set both to none
    document.getElementById("scrapDeleteArea"+index).style.display="none";
    document.getElementById("scrapReplyArea"+index).style.display="none";

    //set target to active
    if (target) {
        document.getElementById(target+""+index).style.display="block";
    }
}


function submitReplyForm(index) {
    replyform = document.getElementById("scrapReplyForm"+index);
    replyform.submit();
  
}

function submitDeleteForm(index) {
    deleteform = document.getElementById("scrapDeleteForm"+index);
    deleteform.submit();
    
}

function submitJoinDesksForm(index) {
    joindesksform = document.getElementById("joinDesksForm"+index);
    joindesksform.submit();
}
/******************UPLOAD PROGRESS**************************/

var UploadProgress  = {
  uploading: null,
  monitor: function(upid,progressURL) {   
    if (!progressURL) {
        progressURL = "/files/progress"
    }
    //if(!this.periodicExecuter) 
    {    
      this.periodicExecuter = new PeriodicalExecuter(function() {                 
                if(!this.uploading) return;                                 
                new Ajax.Request(progressURL+'?upload_id=' + upid);
      }.bind(this), 3);
    }
    this.uploading = true;
    this.StatusBar.create();
  },
  update: function(total, current,resultText) {
    if(!this.uploading) return;
    var status     = current / total;
    var statusHTML = status.toPercentage();
    if (!resultText)
        resultText = statusHTML + "<br /><small>" + current.toHumanSize() + ' of ' + total.toHumanSize() + " uploaded.</small>";

    $('results').innerHTML = resultText
    this.StatusBar.update(status, statusHTML);
  },
  
  finish: function() {
    this.periodicExecuter.stop()
    this.uploading = false;
    this.StatusBar.finish();
    $('results').innerHTML = 'finished!';
  },
  
  cancel: function(msg) {
    if(!this.uploading) return;
    this.uploading = false;
    if(this.StatusBar.statusText) this.StatusBar.statusText.innerHTML = msg || 'canceled';
  },
  
  StatusBar: {
    statusBar: null,
    statusText: null,
    statusBarWidth: 500,
  
    create: function() {
      this.statusBar  = this._createStatus('status-bar');
      this.statusText = this._createStatus('status-text');
      this.statusText.innerHTML  = '0%';
      this.statusBar.style.width = '1px';
    },

    update: function(status, statusHTML) {
      this.statusText.innerHTML = statusHTML;
      newBarwidth = status * this.statusBarWidth
      currBarWidth = parseInt(this.statusBar.style.width)
      grownRatio = 1 + (newBarwidth - currBarWidth) / newBarwidth
      if (currBarWidth * grownRatio > this.statusBarWidth ) {
            //grownRatio = 1.01
      }
      grownPercentage = 100 * grownRatio
      
      new Effect.Scale(this.statusBar, grownPercentage, {scaleY : false});
      //this.statusBar.style.width = Math.floor(this.statusBarWidth * status);
    },

    finish: function() {
      this.statusText.innerHTML  = '100%';
      this.statusBar.style.width = '100%';
    },
    
    _createStatus: function(id) {
      el = $(id);
      if(!el) {
        el = document.createElement('span');
        el.setAttribute('id', id);
        $('progress-bar').appendChild(el);
      }
      return el;
    }
  },
  
  FileField: {
    add: function() {
      new Insertion.Bottom('file-fields', '<p style="display:none"><input id="data" name="data" type="file" /> <a href="#" onclick="UploadProgress.FileField.remove(this);return false;">x</a></p>')
      $$('#file-fields p').last().visualEffect('blind_down', {duration:0.3});
    },
    
    remove: function(anchor) {
      anchor.parentNode.visualEffect('drop_out', {duration:0.25});
    }
  }
}

Number.prototype.bytes     = function() { return this; };
Number.prototype.kilobytes = function() { return this *  1024; };
Number.prototype.megabytes = function() { return this * (1024).kilobytes(); };
Number.prototype.gigabytes = function() { return this * (1024).megabytes(); };
Number.prototype.terabytes = function() { return this * (1024).gigabytes(); };
Number.prototype.petabytes = function() { return this * (1024).terabytes(); };
Number.prototype.exabytes =  function() { return this * (1024).petabytes(); };
['byte', 'kilobyte', 'megabyte', 'gigabyte', 'terabyte', 'petabyte', 'exabyte'].each(function(meth) {
  Number.prototype[meth] = Number.prototype[meth+'s'];
});

Number.prototype.toPrecision = function() {
  var precision = arguments[0] || 2;
  var s         = Math.round(this * Math.pow(10, precision)).toString();
  var pos       = s.length - precision;
  var last      = s.substr(pos, precision);
  return s.substr(0, pos) + (last.match("^0{" + precision + "}$") ? '' : '.' + last);
}

// (1/10).toPercentage()
// # => '10%'
Number.prototype.toPercentage = function() {
  return (this * 100).toPrecision() + '%';
}

Number.prototype.toHumanSize = function() {
  if(this < (1).kilobyte())  return this + " Bytes";
  if(this < (1).megabyte())  return (this / (1).kilobyte()).toPrecision()  + ' KB';
  if(this < (1).gigabytes()) return (this / (1).megabyte()).toPrecision()  + ' MB';
  if(this < (1).terabytes()) return (this / (1).gigabytes()).toPrecision() + ' GB';
  if(this < (1).petabytes()) return (this / (1).terabytes()).toPrecision() + ' TB';
  if(this < (1).exabytes())  return (this / (1).petabytes()).toPrecision() + ' PB';
                             return (this / (1).exabytes()).toPrecision()  + ' EB';
}

var UploadProgress123 = {
  uploading: null,
  monitor: function(upid,uploadingForm,maxUploadSize) {
    
    if(!this.periodicExecuter) {
      this.periodicExecuter = new PeriodicalExecuter(function() {
        if(!UploadProgress.uploading) return;
        //alert('get status with ajax')
        new Ajax.Request('/files/progress?upload_id=' + upid + '&max=' + maxUploadSize)
      }, 0.25);
    }    
        try {$('server-error-message').style.display = "none" }catch(e) {}
    $('upload-progress').style.display='block'
    this.uploading = true;
    this.StatusBar.create();
    this.parentForm = uploadingForm
    this.parentForm.style.display='none'
  },
  update: function(total, current) {
        try {
            if(!this.uploading) return;
            var status     = current / total;
            var statusHTML = status.toPercentage();    
            $('results').innerHTML   = statusHTML + "<br /><small>" + current.toHumanSize() + ' of ' + total.toHumanSize() + " uploaded.</small>";
            this.StatusBar.update(status, statusHTML);
        }catch(e) {}
  },
  
  finish: function() {
   // $('upload-progress').style.display='none'
   // this.parentForm.style.display='block'
    try {
        this.uploading = false;
        this.StatusBar.finish();
        $('results').innerHTML = 'finished!';
     }catch(e) {}
  },
  
  cancel: function(msg) {
    if(!this.uploading) return;
    this.uploading = false;
    if(this.StatusBar.statusText) this.StatusBar.statusText.innerHTML = msg || 'canceled';
  },
  
  StatusBar: {
    statusBar: null,
    statusText: null,
    statusBarWidth: 500,
  
    create: function() {
      this.statusBar  = this._createStatus('status-bar');
      this.statusText = this._createStatus('status-text');
      this.statusText.innerHTML  = '0%';
      this.statusBar.style.width = '0';
    },
    
    update: function(status, statusHTML) {
      this.statusText.innerHTML = statusHTML;           
      this.statusBar.style.width = Math.floor(this.statusBarWidth * status)
      
    },    
   
    finish: function() {
      this.statusText.innerHTML  = '100%';
      this.statusBar.style.width = '100%';
    },
    
    _createStatus: function(id) {
      el = $(id);
      if(!el) {
        el = document.createElement('span');
        el.setAttribute('id', id);
        $('progress-bar').appendChild(el);
      }
      return el;
    }
  },
  
  FileField: {
    numFields: 1,
    add: function() {
      this.numFields++
      id_field = "upload_files[f" + this.numFields + "]"           
      new Insertion.Bottom('file-fields', '<span> <input id="'+ id_field + '" name="'+ id_field + '" type="file" /> <a href="#" onclick="UploadProgress.FileField.remove(this);return false;">remove</a><br></span>')      
    //  $$('#file-fields p').last().visualEffect('blind_down', {duration:0.3});
    },
    
    remove: function(anchor) {
    //      anchor.parentNode.visualEffect('drop_out', {duration:0.25});
    anchor.parentNode.innerHTML = ""
    }
  }
}

Number.prototype.bytes     = function() { return this; };
Number.prototype.kilobytes = function() { return this *  1024; };
Number.prototype.megabytes = function() { return this * (1024).kilobytes(); };
Number.prototype.gigabytes = function() { return this * (1024).megabytes(); };
Number.prototype.terabytes = function() { return this * (1024).gigabytes(); };
Number.prototype.petabytes = function() { return this * (1024).terabytes(); };
Number.prototype.exabytes =  function() { return this * (1024).petabytes(); };
['byte', 'kilobyte', 'megabyte', 'gigabyte', 'terabyte', 'petabyte', 'exabyte'].each(function(meth) {
  Number.prototype[meth] = Number.prototype[meth+'s'];
});

Number.prototype.toPrecision = function() {
  var precision = arguments[0] || 2;
  var s         = Math.round(this * Math.pow(10, precision)).toString();
  var pos       = s.length - precision;
  var last      = s.substr(pos, precision);
  return s.substr(0, pos) + (last.match("^0{" + precision + "}$") ? '' : '.' + last);
}

// (1/10).toPercentage()
// # => '10%'
Number.prototype.toPercentage = function() {
  return (this * 100).toPrecision() + '%';
}

Number.prototype.toHumanSize = function() {
  if(this < (1).kilobyte())  return this + " Bytes";
  if(this < (1).megabyte())  return (this / (1).kilobyte()).toPrecision()  + ' KB';
  if(this < (1).gigabytes()) return (this / (1).megabyte()).toPrecision()  + ' MB';
  if(this < (1).terabytes()) return (this / (1).gigabytes()).toPrecision() + ' GB';
  if(this < (1).petabytes()) return (this / (1).terabytes()).toPrecision() + ' TB';
  if(this < (1).exabytes())  return (this / (1).petabytes()).toPrecision() + ' PB';
                             return (this / (1).exabytes()).toPrecision()  + ' EB';
}

/******************UPLOAD PROGRESS END*********************/





/**************** Project Calendar functions BEGIN**************/

function setupTooltip(number, letter) {
      eval("var tooltip_"+letter+number+" = new Tooltip('"+letter+"trigger_"+number+"', '"+letter+"tooltip_"+number+"')");
	  /*Event.observe(window,"load",function() {
	    $$("*").findAll(function(node){
	      return node.getAttribute('title');
	    }).each(function(node){
	      new Tooltip(node,node.title);
	      node.removeAttribute("title");
	    });
	  });*/
}

function setupLinkTooltip(number, letter) {
      eval("var tooltip_"+letter+number+" = new Tooltip('"+letter+"trigger_"+number+"', '"+letter+"tooltip_')");
      
	  /*Event.observe(window,"load",function() {
	    $$("*").findAll(function(node){
	      return node.getAttribute('title');
	    }).each(function(node){
	      new Tooltip(node,node.title);
	      node.removeAttribute("title");
	    });
	  });*/
}


/**************** Project Calendar functions END **************/
