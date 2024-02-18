require "icu"
require "log"
require "json"
require "colorize"

require "../src/_util/text_util"
require "../src/_util/hash_util"
require "../src/_util/zstd_util"

INP = "/2tb/var.chivi/zroot/ctfile/download"
OUT = "/www/ztext/ctfile"

CSDET = ICU::CharsetDetector.new

CHARS_SAFE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_".chars

def fname_from_cksum(cksum : UInt64)
  String.build do |buf|
    11.times do
      cksum, mod = cksum.divmod(64)
      buf << CHARS_SAFE.unsafe_fetch(mod)
    end
    buf << "-"
  end
end

def process_file(inp_path : String, label = "-/-")
  inp_file = File.open(inp_path, "r")

  test_txt = inp_file.read_string({1024, inp_file.size}.min)
  encoding = CSDET.detect(test_txt).name

  inp_name = File.basename(inp_path)
  puts "- <#{label}> [#{inp_name}] #{encoding.colorize.green} => UTF-8"

  inp_file.rewind
  inp_file.set_encoding(encoding, invalid: :skip)

  str_full = String::Builder.new
  str_desc = String::Builder.new

  char_count = 0
  text_cksum = HashUtil::BASIS_64

  blank_count = 0
  outer_count = 0
  inner_count = 0
  title_count = 0

  inp_file.each_line do |line|
    full_line = CharUtil.fast_sanitize(line)
    str_full << full_line << '\n'

    trim_line = full_line.strip

    if trim_line.empty?
      blank_count &+= 1
      next
    end

    char_count &+= full_line.size
    str_desc << trim_line << '\n' if char_count < 300

    title_count &+= 1 if trim_line[0] == '第'

    text_cksum = HashUtil.fnv_1a_64(trim_line, text_cksum)
    text_cksum = HashUtil.fnv_1a_64('\n', text_cksum)

    if full_line[0].in?(' ', '\t')
      inner_count &+= 1
    else
      outer_count &+= 1
    end
  end

  inp_file.close

  out_name = inp_name.sub(/^.+-/, fname_from_cksum(text_cksum))

  out_json = {
    orig_fname:  inp_name,
    brief_desc:  str_desc.to_s,
    char_count:  char_count,
    text_cksum:  text_cksum,
    title_count: title_count,
    blank_count: blank_count,
    outer_count: outer_count,
    inner_count: inner_count,
  }

  File.write("#{OUT}/#{out_name.sub(".txt", ".json")}", out_json.to_pretty_json)
  ZstdUtil.save_io(str_full.to_s, "#{OUT}/#{out_name}.zst")
end

files = Dir.glob("#{INP}/*.txt.done")

files.each_with_index(1) do |file, idx|
  process_file(file, "#{idx}/#{files.size}")
  # File.rename(file, file + ".done")
rescue ex
  Log.error(exception: ex) { file }
end
