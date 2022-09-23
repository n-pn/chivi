require "json"
require "compress/zip"

class YS::RawCrit
  class Book
    include JSON::Serializable

    getter _id : Int64?

    @[JSON::Field(key: "bookId")]
    getter book_id : Int64?

    getter id : Int64 { _id || book_id || 0_i64 }

    getter title : String
    getter author : String
  end

  struct User
    include JSON::Serializable

    getter _id : Int32

    @[JSON::Field(key: "userName")]
    getter name : String
  end

  include JSON::Serializable

  getter _id : String

  @[JSON::Field(key: "score")]
  getter stars : Int32 = 3

  @[JSON::Field(key: "content")]
  getter ztext : String = ""

  getter tags : Array(String) = [] of String

  @[JSON::Field(key: "praiseCount")]
  getter like_count : Int32 = 0

  @[JSON::Field(key: "replyCount")]
  getter repl_total : Int32 = 0

  # getter createdAt : Time # ignoring

  @[JSON::Field(key: "createdAt")]
  getter created_at : Time?

  @[JSON::Field(key: "updateAt")]
  getter updated_at : Time?

  @[JSON::Field(key: "bookId")]
  getter book : Book?

  @[JSON::Field(key: "createrId")]
  getter user : User?

  alias BookComment = NamedTuple(comments: Array(self), total: Int32)
  alias ListComment = NamedTuple(books: Array(self), total: Int32)

  def self.from_book_json(json : String) : {Array(self), Int32}
    data = NamedTuple(data: BookComment).from_json(json)[:data]
    {data[:comments], data[:total]}
  end

  def self.from_list_json(json : String) : {Array(self), Int32}
    data = NamedTuple(data: ListComment).from_json(json)[:data]
    {data[:books], data[:total]}
  end
end

def save_crit_body(crit : YS::RawCrit, skip_if_exists = true)
  return if crit._id == "ads"

  # save crit body to disk instead of db
  # work in progress
  # TODO: remove crit_body field in db and use zip files insteads

  # do not write file if content is hidden in yousuu
  return if crit.ztext == "请登录查看评论内容" || crit.ztext.empty?

  save_dir = "var/ys_db/crits/#{crit.book.not_nil!.id}-zh"
  Dir.mkdir_p(save_dir)

  # write crit body to {yousuu_id}.zip
  # NOTE: were are using yousuu_id instead of yscrit id prefix
  # so that we can easy look for the custom dict name for the machine translation
  # also to detect some garbage spam reviews (which is already removed from yousuu)

  return if skip_if_exists && in_zip?(save_dir + ".zip", crit._id)

  text_path = "#{save_dir}/#{crit._id}.txt"
  File.write(text_path, crit.ztext)
  puts " file: #{text_path} saved!"
end

def in_zip?(zip_file : String, crit_id : String)
  return false unless File.exists?(zip_file)
  Compress::Zip::File.open(zip_file) do |zip|
    !!zip[crit_id + ".txt"]?
  end
end

#############

# alias BookData = NamedTuple(Book: NamedTuple(commentsResult: NamedTuple(comments: Array(YS::RawCrit))))

# files = Dir.glob("var/ysinfos/archive/books/*.json")

# files.each do |file|
#   puts file
#   data = BookData.from_json(File.read(file))

#   crits = data[:Book][:commentsResult][:comments]
#   crits.each { |crit| save_crit_body(crit, skip_if_exists: true) }
# rescue err
#   puts file, err
# end

alias ListData = NamedTuple(Booklist: NamedTuple(books: Array(YS::RawCrit)))

files = Dir.glob("var/ysinfos/archive/booklists/*.json")

files.each do |file|
  puts file

  data = ListData.from_json(File.read(file))
  crits = data[:Booklist][:books]
  crits.each { |crit| save_crit_body(crit, skip_if_exists: true) }
rescue err
  puts file, err
end
