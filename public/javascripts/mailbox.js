function hoverImage(imageURL,domID) {
     id = "s" + Math.floor(Math.random() * 100000000000)
     new Insertion.Bottom(domID,"<div id='" + id + "'><img src='"+imageURL+"' /></div>")
     hoverDOM = $(id)
     return new Tooltip(domID,hoverDOM)
}
var MailBox = {  
  selectMessages : function(select) {   
    select = $(select)    
    switch(select.selectedOption().value){
        case "All":cssRule = 'input[type="checkbox"]' ;break;
        case "Read":cssRule = 'input[type="checkbox][read="read"]' ;break;
        case "Unread":cssRule = 'input[type="checkbox][read="not-read"]' ;break;        
        case "None":cssRule = 'input[type="checkbox" select="false"]';       
        default:cssRule = 'input[type="checkbox" select="false"]';select.selectedIndex = 0;
            
    }     

    $$('input[type="checkbox"]').each(function(e){       
        if (e.match(cssRule))    
            e.checked=true;
        else
            e.checked=false;
    });
    this.showMessageOptions();
    
  },
  markRead : function(read) {
     $('actionForm').action = '/my/mark_message/'+read;     
     $('actionForm').submit();
  
  },
  saveMessages : function() {
     $('actionForm').action = '/my/save_message';
     $('actionForm').submit();
  },
  delMessages : function() {        
        $('actionForm').action = '/my/delete_message';
        $('actionForm').submit();
  },  
  showMessageOptions : function() {
    checked = false;
    $$('input[type="checkbox"]').each(function(e){       
         
		 if (e.checked) {
            checked = true;
            throw $break;
         }                
    });  
    elements = $$("#actionLinks A");        
    if (!checked) {
       
		$("actionLinks").addClassName('disabled-link');
        elements.each(function(e){
            e.onclickHandler = e.onclick || function(){return true;};
            e.onclick = function() { return false};           
        });    
    }else {
        $("actionLinks").removeClassName('disabled-link');
        elements.each(function(e){
           if (e.onclickHandler) {
               e.onclick = e.onclickHandler;
             
           }
        });        
    }
  },
  addName : function(array) {
    array.each(function(o){
         span = $('s'+o.id);
         if (!span){
                new Insertion.Top('to',
                                "<span style=';margin-right:2px;padding:2px;' type='recipient' class='status-box bold-link-div' id='s" + o.id + "'>" +                                                           
                                     "<input type='hidden' name='recipients[]' value='"+o.id+ "'/>" +
                                     "<a href='#' onclick='this.parentNode.remove();MailBox.check();return false;'>x</a>&nbsp;" +                                                             
                                "</span>");
                s = $('s'+o.id);                                              
                new Insertion.Bottom(s,o.fullName);     
          }                                                              
    }.bind(this));
    this.check();                               
  },  
  anyRecipientSelected : function(){
        
        return $('to').down('span[type="recipient"]') != null;
  
  },                         
  check : function() {
   
   if(!$('to').down('span[type="recipient"]')){
        new Insertion.Bottom($('to'),"<span class='status-box' style='margin:0 !important;padding:2px' id='noFriend'>Select a friend</span>");
   }else {
        if ($('noFriend')) {
            $('noFriend').remove();
        }
   } 
  },
  moveFriendFromSelect : function() {
        
        $('left').eachSelectedOption(function(option){                                        
            this.addName([option.getAttribute('object').evalJSON()]);
            
        }.bind(this));
        
                                       
                                     
  } 
}
