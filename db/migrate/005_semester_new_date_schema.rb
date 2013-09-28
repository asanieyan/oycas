class SemesterNewDateSchema < ActiveRecord::Migration
  def self.up    
    require 'lib/school/lib/school_config'    
    create_table "string_counters", :force => true do |t|    
      t.column "string_entry", :string, :limit => 500, :unique=>true
      t.column "count", :integer, :limit =>5      
    end   rescue p 'table exists '
    remove_column :semesters,"__year__"  rescue p 'no column '
    remove_index  :semesters,:name=>"school_id_2" rescue  p 'no column '
    add_column :seasons, :season_index,:integer,:limit=>1 rescue  p 'column exists '
#    add_column :seasons, :class_start,:string,:limit=>10
#    add_column :seasons, :class_end,:string,:limit=>10        
#    add_column :seasons, :exam_end,:string,:limit=>10  
    add_column :schools,:rss_news_feed,:string,:limit=>500 rescue  p 'column exists '

    add_column :semesters, :start_date,:datetime rescue  p 'column exists '
    add_column :semesters, :end_date,:datetime rescue  p 'column exists '
    School.find(:all).each do |school|
        school_configu = SchoolConfigurator.new(school)
        school.rss_news_feed = school_configu.school_info['rss_news_feed']
        school.save
        school_configu.semesters.each_with_index do |semester,i|
          season = Season.find_by_school_id_and_name(school.id,semester['name'])
          season.season_index = i + 1
          season.save
        end
    end
    Semester.find(:all).each do |semester|
      semester.start_date = semester.season.start_date
      semester.end_date = semester.season.end_date
      semester.save
    end
    add_column :semesters, :class_start,:datetime rescue  p 'column exists '
    add_column :semesters, :class_end,:datetime rescue  p 'column exists '
    add_column :semesters, :exam_end,:datetime rescue p 'column exists '
#    add_column :students,:newsletter_notification,:enum, :limit => [:y]     
  end
  def self.down
#    add_column :seasons, "start_month", :integer, :limit => 6
#    add_column :seasons, "end_month", :integer, :limit => 6    
#    remove_column :students,:newsletter_notification 
    
    drop_table :string_entry rescue p 'no table '
    remove_column :schools,:rss_news_feed rescue p 'no column '
    remove_column :seasons, :season_index rescue p 'no column '
#    remove_column :seasons, :class_start rescue
#    remove_column :seasons, :class_end rescue
#    
#    remove_column :seasons, :exam_end rescue
    
    remove_column :semesters, :start_date  rescue p 'no column '
    remove_column :semesters, :end_date rescue p 'no column ' 
    remove_column :semesters, :class_start  rescue p 'no column ' 
    remove_column :semesters, :class_end  rescue p 'no column ' 
    remove_column :semesters, :exam_end rescue p 'no column ' 
    
  end
end
