require "../../tabkv/*"
require "../../libcv/cvmtl"
require "../../utils/text_utils"

module CV::NvUtils
  extend self

  def to_hanviet(input : String, caps : Bool = true)
    return input if input =~ /^[\w\s_.]+$/

    output = Cvmtl.hanviet.translit(input, false).to_s
    caps ? TextUtils.titleize(output) : output
  end

  def cleanup_name(name : String)
    name.sub(/[（\(].+[\)）]$/, "").strip
  end

  FIX_DIR = "src/appcv/nv_info/_fixes"

  def fix_map(name : String)
    ValueMap.new("#{FIX_DIR}/#{name}.tsv", mode: 2)
  end
end
