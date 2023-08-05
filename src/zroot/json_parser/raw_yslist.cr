require "./_raw_base"

class ZR::RawYslist
  include JSON::Serializable

  @[JSON::Field(key: "_id")]
  getter _id : String = ""

  @[JSON::Field(key: "booklistId")]
  getter yl_id : String = ""

  @[JSON::Field(key: "createrId")]
  getter user : EmbedYsuser?

  @[JSON::Field(key: "title")]
  getter zname : String

  @[JSON::Field(key: "content")]
  getter zdesc : String = ""

  @[JSON::Field(key: "listType")]
  getter klass : String = "male"

  @[JSON::Field(key: "clicks")]
  getter view_count : Int32 = 0

  @[JSON::Field(key: "praiseTotal")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "favsTotal")]
  getter star_count : Int32 = 0

  @[JSON::Field(key: "bookTotal")]
  getter book_total : Int32 = 0

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time?

  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time

  @[JSON::Field(key: "praiseAt")]
  getter praised_at : Time

  ###################

  def self.from_json(string_or_io : String | IO) : self
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end

struct ZR::RawYsbooklists
  include JSON::Serializable

  @[JSON::Field(key: "booklists")]
  getter lists : Array(RawYslist)

  getter total : Int32

  def self.from_json(string_or_io : String | IO)
    parser = JSON::PullParser.new(string_or_io)
    parser.on_key!("data") { new(parser) }
  end
end
