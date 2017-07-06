class Comment < ApplicationRecord

  validates_presence_of :commenter

  belongs_to :post
end
