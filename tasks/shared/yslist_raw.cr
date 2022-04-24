require "log"
require "json"
require "./bootstrap"

class CV::YslistRaw
  class User
    include JSON::Serializable

    getter _id : Int64

    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String
  getter id : Int64 { _id[12..].to_i64(base: 16) }

  @[JSON::Field(key: "createrId")]
  getter user : User

  @[JSON::Field(key: "clicks")]
  getter view_count : Int32 = 0

  @[JSON::Field(key: "praiseTotal")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "favsTotal")]
  getter star_count : Int32 = 0

  @[JSON::Field(key: "bookTotal")]
  getter book_total : Int32 = 0

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time
  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time

  @[JSON::Field(key: "praiseAt")]
  getter praised_at : Time

  @[JSON::Field(key: "title")]
  getter zname : String

  @[JSON::Field(key: "content")]
  getter zdesc : String = ""

  @[JSON::Field(key: "listType")]
  getter klass : String = "male"

  @[JSON::Field(key: "booklistId")]
  getter list_id : String = ""

  def seed!(stime : Int64 = Time.utc.to_unix)
    list = Yslist.get!(self.id, self.created_at)

    list.origin_id = self._id
    list.ysuser = Ysuser.upsert!(self.user.name)

    list.set_name(self.zname)
    list.set_desc(self.zdesc)

    list.stime = stime
    list.utime = self.updated_at.to_unix

    list.book_total = self.book_total if self.book_total < list.book_total
    list.like_count = self.like_count if self.like_count < list.like_count

    list.view_count = self.view_count if self.view_count < list.view_count
    list.star_count = self.star_count if self.star_count < list.star_count

    list.fix_sort!
    list.save!
  rescue err
    Log.error { err.inspect_with_backtrace.colorize.red }
  end

  ###################

  alias Data = NamedTuple(total: Int32, booklists: Array(self))

  def self.from_list(data : String) : Data
    NamedTuple(data: Data).from_json(data)[:data]
  end

  def self.from_info(data : String) : self
    NamedTuple(data: self).from_json(data)[:data]
  end
end
