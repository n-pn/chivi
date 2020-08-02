require "colorize"
require "file_utils"
require "../../utils/file_util"

# module BaseFileDB(T)
#   SEP_0 = "ǁ"
#   SEP_1 = "¦"

#   getter file : String

#   def initialize(@file, mode = 0)
#     return if mode == 0
#     load!(@file) if mode == 2 || File.exists?(file)
#   end

#   abstract def type : String
#   abstract def size : Int32

#   abstract def read_line(line : String)

#   def load!(file : String = @file) : Void
#     FileUtil.each_line(file, LABEL) do |line|
#       read_line(line)
#     rescue err
#       puts "- <#{type.colorize.red}> error parsing `#{line.colorize.red}`\
#     : #{err.colorize.red}"
#     end
#   end

#   abstract def serialize(io : IO, val : T)

#   def serialize(io : IO, key : String, val : T)
#     io << key
#     serialize(io, val)
#     io << "\n"
#   end

#   def append!(key : String, val : T) : Void
#     File.open(@file, "a") { |io| serialize(io, key, val) }
#   end

#   abstract def each(&block : Tuple(String, T) -> Void)

#   def serialize(io : IO)
#     each do |key, val|
#       serialize(io, key, val)
#     end
#   end

#   def save!(file : String = @file) : Void
#     FileUtil.save(file, type, size) { |io| serialize(io) }
#   end

#   abstract def upsert(key : String, val : T)

#   def upsert!(key : String, val : T)
#     append!(key, val) if upsert(key, val)
#   end

#   abstract def delete(key : String)

#   def delete!(key : String)
#     File.open(@file, "a") { |io| io.puts(key) } if delete(key)
#   end

#   CACHE = {} of String => self

#   def self.preload!(name : String) : self
#     CACHE[name] ||= load(name) || init(name)
#   end

#   def self.flush!
#     CACHE.each_value { |item| item.save! }
#   end
# end
