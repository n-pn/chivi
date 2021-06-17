require "./_setup"

class CV::Bgenre
  include Clear::Model

  primary_key type: serial

  column vi_name : String
  column vi_slug : String

  column zh_names : Array(String) # mapping chinese genre to vietnamese one
end
