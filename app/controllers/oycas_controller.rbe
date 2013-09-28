class OycasController < ApplicationController
  skip_before_filter :authorize ,:except=>"post_comment"
  before_filter :set_custom_style
  before_filter :check_admin,:only=>%w(post_blog delete_blog)
  private 
   def check_admin
     return true if @admin
     return false
   end
  public   
  def set_custom_style     
        @controller_custom = <<-eof
          <style>
            #content-panel{            
              padding:20px;
              background-color:white !important;
              height:200px;  
              border-top:1px solid #C0C0C0;                         
            }            
          </style>  
        eof
  end 
  def about
  
  end 
  def delete_comment
     
    comment = Comment.find(params[:id])rescue nil
    if comment and (@admin or comment.student == @me)
      comment.destroy
    end
    redirect_to :back
  end
  def post_comment
    begin    
      @blog = OycasBlog.find(params[:id])       
      raise if @admin
      comment = Comment.new(:student_id=>@my.id,:comment=>params[:comment])
      comment.commentable = @blog
      comment.save
      redirect_to :action=>"blog",:id=>@blog.id
      
    rescue Exception=>e
        p e.message
        redirect_to :action=>"blogs"
    end    
  end
  def delete_blog    
    OycasBlog.find(params[:id]).destroy rescue ""
    redirect_to :back
  end
  
  def blog
    begin 
       @blog = OycasBlog.find(params[:id]) 

       
    rescue
        redirect_to :action=>"blogs"    
        return
    end
    
    
  end
  def post_blog
    if request.post?
      flash[:blog] = {:subject=>params[:blog][:subject],:text=>params[:blog][:text]}    
      attributes = {:subject=>params[:blog][:subject],:text=>params[:blog][:text]}
      blog = begin 
              blog = OycasBlog.find(params[:id]);
              blog.attributes=(attributes)
              blog.save;
              blog
             rescue Exception=>e
#                p e.message
                OycasBlog.create(attributes)
             end
      if not blog.errors.empty?
        r_msg "blog_error"=>blog.errors      
        redirect_to :back
      else
        redirect_to :action=>"blogs",:m=>blog.month_id
      end
    else
      @blog = OycasBlog.find(params[:id]) rescue OycasBlog.new
      if flash[:blog] 
       @blog.subject = flash[:blog][:subject]
       @blog.text = flash[:blog][:text]
      end
    end
  end  
  def blogs
    @blogs = []
    if params[:m]
       @blogs =  OycasBlog.find(:all,:conditions=>["month_id LIKE ?",params[:m]])       
    end       
    if @blogs.empty?  and  blog = OycasBlog.find(:first,:order=>"created_on DESC")     #at least one entry 
            latest_blog_month_id = blog.month_id rescue nil
            redirect_to :action=>"blogs",:m => latest_blog_month_id        
            return
     end    
    
  end
  
end


