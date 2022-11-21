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

  PTAG_MAP = {} of String => Int32
  PTAG_STR = {} of Int32 => String
  ROLE_MAP = {} of Int32 => Array(Int32)

  files = Dir.glob("src/cvmtl/mt_data/pos_tag/*.yml")
  files.sort_by! { |x| File.basename(x, ".yml").split('-').first.to_i }

  files.each do |file|
    File.open(file, "r") do |io|
      Array(Entry).from_yaml(io).each do |entry|
        ptag = map_tag(entry.ptag)

        roles = entry.extd.each_with_object([ptag]) do |extd, memo|
          next unless extd_roles = ROLE_MAP[map_tag(extd)]?
          memo.concat(extd_roles)
        end

        ROLE_MAP[ptag] = roles.uniq!
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

  # puts PTAG_MAP, ROLE_MAP
  # puts EXTD_MAP.to_a.max_by(&.[1].size)
  # puts PTAG_MAP.find { |k, v| v == 39 }
end
