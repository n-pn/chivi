require "json"

class Oldcv::YsReview
  include JSON::Serializable

  getter _id : Int32

  getter bookId : NamedTuple(_id: Int32, title: String, author: String)
  getter createrId : NamedTuple(_id: Int32, userName: String)

  getter createdAt : Time
  getter updateAt : Time?

  getter content : String
  getter score : Int32

  getter replyCount : Int32
  getter praiseCount : Int32
end
