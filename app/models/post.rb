class Post < ApplicationRecord

  validates_presence_of :author, :title, :body

  has_many :comments, :dependent => :destroy

end
