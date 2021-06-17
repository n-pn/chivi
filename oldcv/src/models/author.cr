require "./_setup"

class CV::Author
  include Clear::Model

  primary_key type: serial

  column zh_name : String
  column vi_name : String

  # for text search
  column zh_slug : String
  column vi_slug : String

  column sorting : Int32, presence: false # weight of author top rated book
end
