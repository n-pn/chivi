require "colorize"

ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"
require "../../src/mt_sp/data/qt_data"

struct Input
  include DB::Serializable
  getter id : Int32, ztext : String

  getter lines : Array(String) do
    @ztext.lines.compact_map do |line|
      line = line.gsub('\u003c', '<').gsub(/\p{Cc}/, "").strip
      line unless line.empty?
    end
  end

  def self.split_chunk(input : Array(self))
    texts = [[] of String]

    total = 0
    limit = 4500

    input.each do |entry|
      entry.lines.each do |zline|
        texts.last << zline
        total += zline.size + 1

        next if total < limit
        texts << [] of String
        total = 0
      end
    end

    texts.pop if texts.last.empty?
    texts
  end

  CACHE_DIR = "/2tb/zroot/ydata"

  def self.translate_batch(input : Array(self), method = "bd_zv", index = 1, char_total = 0, cache_name = "yscrit")
    texts = split_chunk(input)
    trans = [] of String

    texts.each_with_index(1) do |lines, index_2|
      char_count = lines.sum(&.size) + lines.size
      char_total += char_count

      Log.info { "<#{index}-#{index_2}> #{char_count} chars".colorize.cyan }

      qdata = SP::QtData.from_ztext(lines, cache_dir: "#{CACHE_DIR}/#{cache_name}")
      vtext, mtime = qdata.get_vtran(method)
      trans.concat(vtext.lines)

      Log.info { " cached at: #{Time.unix(mtime)}" }
      Log.info { " lines: #{trans.size}, total: #{char_total}".colorize.green }
    end

    {trans, char_total}
  end
end
