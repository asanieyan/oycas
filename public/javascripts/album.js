Ajax.InPlaceEditor.defaultHighlightColor = "#DDDDDD";
var Album = {    
    photos : function(){return $$("input[type='checkbox']");},
    actionLinks : function(){ return $$('#photoActionLinks A');},       
    renderSimpleUpload : function() {
        $('upload-form').update($('simple-upload').innerHTML);
    },
    highlightThumb : function(id) {
        $(id).style.backgroundColor = '#FF7400';
    },
    dehighlighThumb: function(id) {
        
          $(id).style.backgroundColor = '';
    },
    selectPhoto : function(selectE){
            select = $(selectE);
            if (select.selectedOption().value == "None") {
                this.photos().each(function(e){
                        e.checked = false;
                });
                select.selectedIndex = 0;
                this.disableActions();
            }else if (select.selectedOption().value == "All")  {
                 this.photos().each(function(e){
                        
                        e.checked = true;
                        
                }); 
              this.enableActions();                        
            }
 
    },  
    addFileFields : function() {
        
        new Insertion.Bottom('photo-files','<div> <input name="File'+ Math.floor(Math.random()*1000000)+'" type="file" /></div>')
    
    }, 
    disableActions : function() {
        this.actionLinks().each(function(l){
            $(l).disableLink();
        });
        try{
            $('new_album').disabled = true;
        }catch(e){}
     
    }, 
    enableActions : function() {
        this.actionLinks().each(function(l){
            $(l).enableLink();
        });
        try{
            $('new_album').disabled = false;
        }catch(e){}

    }, 
    deletePhotos : function(){

        $('photo_action').value = "Delete";
        $('albumForm').submit();
        
    },
    movePhotos : function(){
        $('photo_action').value = "Move";
        $('albumForm').submit();
        
    },    
    showOptions : function() {   

         anyPhotoChecked = false;
         this.photos().each(function(photo){
            if (photo.checked) {
                anyPhotoChecked = true;
                throw $break;
            }
            
         });
         if (anyPhotoChecked) {
            this.enableActions();
         }else {
            this.disableActions();
         }
    
    }
}
