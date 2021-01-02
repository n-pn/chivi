require "mime"
require "digest"
require "colorize"
require "file_utils"

require "../src/filedb/stores/*"

CACHED = Dir.glob("_db/_seeds/.cover/.miscs/*/*.*").each_with_object({} of String => String) do |file, hash|
  hash[File.basename(file).sub(/\..+$/, "")] = file
end

puts CACHED.size

def move_files(seed : String)
  dir = "_db/_seeds/#{seed}/covers"
  FileUtils.mkdir_p(dir)

  input = CV::ValueMap.new("_db/_seeds/#{seed}/bcover.tsv")

  input.data.each_with_index do |(key, vals), idx|
    fname = Digest::SHA1.hexdigest(vals.first)[0..10]
    next unless inp_file = CACHED[fname]?

    puts "- <#{idx + 1}/#{input.size}> #{inp_file}"

    out_file = "#{dir}/#{key}#{File.extname(inp_file)}"
    FileUtils.mv(inp_file, out_file)
  rescue err
    puts err
  end
end

seeds = ARGV.empty? ? ["zhwenpg"] : ARGV
seeds.each { |seed| move_files(seed) }
