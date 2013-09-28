class Comment < ActiveRecord::Base
  belongs_to :commentable ,:polymorphic=>true
  belongs_to :student
  
  strip_tags_and_truncate 'comment'
  validates_presence_of "comment"
end
