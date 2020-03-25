require "json"

class Kernel::Book
  include JSON::Serializable

  property zh_slug : String
  property vi_slug : String

  property zh_title : String
  property vi_title : String

  property zh_author : String
  property vi_author : String

  property zh_intro : String
  property vi_intro : String

  property zh_genre : String
  property vi_genre : String

  property zh_tags : Array(String)
  property vi_tags : Array(String)

  property covers : Array(String)

  property status : Int32
  property hidden : Int32

  property votes : Int32
  property score : Float64
  property tally : Float64

  property word_count : Int32
  property chap_count : Int32

  property review_count : Int32

  property updated_at : Int64

  property _yousuu_bids : Array(Int32)
  property _origin_urls : Array(String)
  property _scrap_sites : Array(String)
  property _scrap_bsids : Array(String)
end
