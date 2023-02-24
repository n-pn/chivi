require "./_common"

class YS::RawYsList
  include JSON::Serializable

  getter _id : String = ""

  @[JSON::Field(key: "booklistId")]
  getter list_id : String = ""

  @[JSON::Field(key: "createrId")]
  getter user : EmbedUser?

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

  def db_values(rtime : Int64 = Time.utc.to_unix)
    {
      @_id.empty? ? @list_id : @_id, # uuid
      @user.try(&.id) || 0,          # user_id

      @zname,
      @zdesc,
      @klass,

      @view_count,
      @like_count,
      @star_count,
      @book_total,

      @updated_at.to_unix, # updated at
      rtime,               # crawled at
    }
  end

  ###################

  record ListJson, booklists : Array(RawYsList), total : Int32 do
    include JSON::Serializable
  end

  def self.from_list_json(json : String) : {Array(self), Int32}
    data = NamedTuple(data: ListJson).from_json(json)[:data]
    {data.booklists, data.total}
  end

  def self.from_info_json(json : String) : self
    NamedTuple(data: self).from_json(json)[:data]
  end
end
