require "../../src/_util/char_util"
require "../../src/_util/viet_util"
require "../../src/mt_ai/data/mt_defn"

INP_PATH = "var/mtapp/v1dic/v1_defns.dic"

struct Input
  include DB::Serializable
  include DB::Serializable::NonStrict

  getter dic : Int32 = 0
  getter tab : Int32 = 0

  getter key : String = ""
  getter val : String = ""

  getter ptag : String = ""

  getter uname : String = ""
  getter mtime : Int64 = 0

  SPLIT = 'ǀ'
end

def export_space_terms
  re = /[上下内外前后中里间底顶处头左右末边後东西南北]$/

  input = DB.open("sqlite3:#{INP_PATH}?immutable=1") do |db|
    query = "select key, val from defns where dic = -1 and ptag = 'ns' order by mtime desc"
    db.query_all query, as: {String, String}
  end

  input.uniq!(&.[0])
  # puts input.select(&.[0].matches?(re))

  File.open("var/mtdic/mt_ai/.fix/space-mt1.tsv", "w") do |file|
    input.each do |zstr, vstr|
      next unless zstr.matches?(re)
      file << zstr << '\t' << "NN" << '\t' << vstr.split('ǀ').first << '\t'
      file << "Ndes" << '\n'
    end
  end
end

def export_attri_terms
  input = DB.open("sqlite3:#{INP_PATH}?immutable=1") do |db|
    query = "select key, val from defns where dic = -1 and ptag = 'na' order by mtime desc"
    db.query_all query, as: {String, String}
  end

  input.uniq!(&.[0])
  puts input

  File.open("var/mtdic/mt_ai/.fix/attri-mt1.tsv", "w") do |file|
    input.each do |zstr, vstr|
      file << zstr << '\t' << "NN" << '\t' << vstr.split('ǀ').first << '\t'
      file << "Ndes" << '\n'
    end
  end
end

# export_space_terms
export_attri_terms
