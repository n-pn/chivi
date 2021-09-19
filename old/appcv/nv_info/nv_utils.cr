require "../../../cutil/*"
require "../../../libcv/*"
require "../../../cutil/text_utils"

module CV::NvUtils
  extend self

  def to_hanviet(input : String, caps : Bool = true)
    return input if input =~ /^[\w\s_.]+$/

    output = MtCore.hanviet_mtl.translit(input, false).to_s
    caps ? TextUtils.titleize(output) : output
  end

  def cleanup_name(name : String)
    name.sub(/[（\(].+[\)）]$/, "").strip
  end

  FIX_DIR = "db/nv_fixes"

  def fix_map(name : String)
    TsvStore.new("#{FIX_DIR}/#{name}.tsv", mode: 2)
  end
end
