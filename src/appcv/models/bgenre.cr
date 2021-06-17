class CV::Bgenre < Granite::Base
  connection pg
  table bgenres

  column id : Int32, primary: true
  timestamps

  column vi_name : String
  column vi_slug : String

  # mapping chinese genre to vietnamese one
  column zh_names : Array(String) = [] of String
end
