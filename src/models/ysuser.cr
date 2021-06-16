require "./_setup"

class CV::Ysuser
  include Clear::Model

  primary_key type: serial

  column origin_id : Int32 # origin yousuu user id

  column zh_name : String # original name
  column vi_name : String # translation
end
