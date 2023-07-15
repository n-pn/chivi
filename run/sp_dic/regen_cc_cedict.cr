require "json"
require "colorize"
require "http/client"
require "compress/zip"

require "../../src/mt_sp/data/wd_defn"

URL = "https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.zip"
DIR = "var/cvmtl/spdic"

ZIP_FILE = "#{DIR}/cc-cedict.zip"
PY_TONES = Hash(String, String).from_json File.read("#{__DIR__}/pinyin-tones.json")

def fetch_zip(output : String)
  tls = OpenSSL::SSL::Context::Client.insecure
  puts "- fetching latest CC_CEDICT from internet... ".colorize.light_cyan

  HTTP::Client.get(URL, tls: tls) do |res|
    File.open(output, "wb") { |file| IO.copy res.body_io, file }
  end
end

def file_outdated?(file : String, expiry : Time::Span = 1.days)
  return true unless File.exists?(file)
  File.info(file).modification_time < Time.utc - expiry
end

def clean_senses(sense : String) : String
  sense
    .gsub(/\p{Han}+\|/, "") # remove trads
    .gsub(/(?<=\[)(.*?)(?=\])/) { |py| pinyin_tones(py) }
end

def pinyin_tones(input : String)
  input.downcase.gsub("u:", "ü").split(/[\s\-]/x).map { |x| PY_TONES.fetch(x, x) }.join(" ")
end

LINE_RE = /^(.+?) (.+?) \[(.+?)\] \/(.+)\/$/

def parse_line(line : String)
  raise "invalid format" unless match = LINE_RE.match(line)

  _, trad, simp, pinyin, senses = match
  pinyin = pinyin_tones(pinyin)
  senses = clean_senses(senses).split('/').join("; ")

  defn = "[#{pinyin}] {#{trad}} #{senses}"
  SP::WdDefn.new(simp, defn)
end

def read_data(zip_file : String, expiry = 24.hours)
  fetch_zip(zip_file) if file_outdated?(zip_file, expiry)

  lines = Compress::Zip::File.open(zip_file) do |zip|
    zip["cedict_ts.u8"].open(&.gets_to_end).split('\n')
  end

  lines.compact_map do |line|
    next if line.empty? || line.starts_with?('#')
    parse_line(line.strip)
  rescue err
    puts err, line
  end
end

defns = read_data(ZIP_FILE)
puts "input: #{defns.size}"

SP::WdDefn.init_db("cc_cedict", reset: true)
SP::WdDefn.upsert("cc_cedict", defns)
# TL::LuTerm.remove_dup!("cc_cedict")
