require "json"
require "./sbook"

class VSite
  include JSON::Serializable

  property bsid = ""
  property mtime = 0_i64
  property chaps = 0

  def initialize(book : SBook)
    @bsid = book.bsid
    @mtime = book.mtime
    @chaps = book.chaps
  end

  def initialize(@bsid = "", @mtime = 0_i64, @chaps = 0)
  end

  def to_s(io)
    to_json(io)
  end
end
