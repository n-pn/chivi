require "log"
require "json"
require "./bootstrap"

class CV::YslistRaw
  class User
    include JSON::Serializable

    getter _id : Int32

    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String = ""

  @[JSON::Field(key: "booklistId")]
  getter list_id : String = ""

  getter oid : String { _id.empty? ? list_id : _id }

  @[JSON::Field(key: "createrId")]
  getter user : User?

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

  @[JSON::Field(key: "title")]
  getter zname : String

  @[JSON::Field(key: "content")]
  getter zdesc : String = ""

  @[JSON::Field(key: "listType")]
  getter klass : String = "male"

  def seed!(stime : Int64 = Time.utc.to_unix, ysuser : Ysuser? = nil)
    yslist = Yslist.upsert!(self.oid, self.created_at || self.updated_at)

    yslist.ysuser = ysuser || begin
      user = self.user.not_nil!
      Ysuser.upsert!(user.name, user._id)
    end

    yslist.set_name(self.zname)
    yslist.set_desc(self.zdesc)

    yslist.klass = klass
    yslist.stime = stime
    yslist.utime = self.updated_at.to_unix

    yslist.book_total = self.book_total if self.book_total > yslist.book_total
    yslist.like_count = self.like_count if self.like_count > yslist.like_count

    yslist.view_count = self.view_count if self.view_count > yslist.view_count
    yslist.star_count = self.star_count if self.star_count > yslist.star_count

    yslist.fix_sort!
    yslist.save!
  rescue err
    Log.error { err.inspect_with_backtrace.colorize.red }
  end

  ###################

  alias Data = NamedTuple(booklists: Array(self), total: Int32)

  def self.from_list(data : String) : {Array(self), Int32}
    data = NamedTuple(data: Data).from_json(data)[:data]
    {data[:booklists], data[:total]}
  end

  def self.from_info(data : String) : self
    NamedTuple(data: self).from_json(data)[:data]
  end
end
