require "json"
require "tabkv"

struct User
  include JSON::Serializable

  getter _id : Int32

  @[JSON::Field(key: "userName")]
  getter name : String
end

output = Tabkv(Int32).new("var/ysinfos/ysusers.tsv")

alias Comment = NamedTuple(fromId: User)
alias Data = NamedTuple(commentReply: Array(Comment))

DIR = "_db/yousuu/repls"
groups = Dir.children(DIR)
groups.each do |group|
  puts "[#{group}]"

  files = Dir.glob("#{DIR}/#{group}/*.json")
  files.each do |file|
    json = NamedTuple(data: Data).from_json(File.read(file))[:data][:commentReply]
    json.each do |comment|
      user = comment[:fromId]
      output.append!(user.name, user._id)
    end
  rescue err
    puts err
  end
end

# alias Comment = NamedTuple(createrId: User)
# alias Data = NamedTuple(books: Array(Comment))

# DIR = "_db/yousuu/list-books-by-score"
# groups = Dir.children(DIR)
# groups.each do |group|
#   puts "[#{group}]"

#   files = Dir.glob("#{DIR}/#{group}/*.json")
#   files.each do |file|
#     json = NamedTuple(data: Data).from_json(File.read(file))[:data][:books]
#     json.each do |comment|
#       user = comment[:createrId]
#       output.append!(user.name, user._id)
#     end
#   rescue err
#     puts err
#   end
# end
