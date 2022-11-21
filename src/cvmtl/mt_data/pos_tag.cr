require "log"
require "yaml"

module MT::PosTag
  struct Entry
    include YAML::Serializable

    getter ptag : String
    getter extd = [] of String
    # getter name : String
    # getter desc : String = ""
  end

  PTAG_MAP = Hash(String, Int32).new
  PTAG_STR = Hash(Int32, String).new

  EXTD_MAP = Hash(Int32, Array(Int32)).new { |h, k| h[k] = [] of Int32 }

  files = Dir.glob("src/cvmtl/engine/pos_tag/*.yml")
  files.sort_by! { |x| File.basename(x, ".yml").split('-').first.to_i }

  files.each do |file|
    File.open(file, "r") do |io|
      Array(Entry).from_yaml(io).each do |entry|
        tag_id = map_tag(entry.ptag)
        extends = [] of Int32

        entry.extd.each do |ptag|
          ext_id = map_tag(ptag)
          extends << ext_id
          EXTD_MAP[ext_id]?.try { |x| extends.concat(x) }
        end

        EXTD_MAP[tag_id] = extends.uniq!
      end
    end
  rescue err
    Log.error(exception: err) { file }
  end

  def self.map_tag(str : String)
    PTAG_MAP[str] ||= (PTAG_MAP.size &+ 1).tap { |x| PTAG_STR[x] = str }
  end

  def self.tag_str(tag : Int32)
    PTAG_STR[tag]? || "N/A"
  end

  # puts PTAG_MAP, EXTD_MAP
  # puts EXTD_MAP.to_a.max_by(&.[1].size)
  # puts PTAG_MAP.find { |k, v| v == 39 }
end
