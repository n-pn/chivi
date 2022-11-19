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

  PTAG_MAP = Hash(String, Int32).new { |h, k| h[k] = h.size + 1 }
  PTAG_STR = Hash(Int32, String).new

  EXTD_MAP = Hash(Int32, Array(Int32)).new { |h, k| h[k] = [] of Int32 }

  files = Dir.glob("src/cvmtl/pos_tag/init/*.yml")
  files.sort_by! { |x| File.basename(x, ".yml").split('-').first.to_i }

  files.each do |file|
    File.open(file, "r") do |io|
      Array(Entry).from_yaml(io).each do |entry|
        tag_id = PTAG_MAP[entry.ptag]
        PTAG_STR[tag_id] = entry.ptag

        EXTD_MAP[tag_id] = entry.extd.each_with_object([] of Int32) do |item, memo|
          ext_id = PTAG_MAP[item]
          memo << ext_id
          memo.concat(EXTD_MAP[ext_id]).uniq!
        end
      end
    end
  rescue err
    Log.error(exception: err) { file }
  end

  # puts PTAG_MAP, EXTD_MAP
  # puts EXTD_MAP.to_a.max_by(&.[1].size)
  # puts PTAG_MAP.find { |k, v| v == 39 }
end
