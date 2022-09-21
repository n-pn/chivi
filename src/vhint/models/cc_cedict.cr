require "./_shared"

class VP::CeTerm
  property trad = ""
  property simp = ""
  property pinyin = ""
  property senses = [] of String

  def initialize(@trad, @simp, @pinyin, @senses)
  end

  RAW_RE = /^(.+?) (.+?) \[(.+?)\] \/.+\/$/

  def self.from_raw(line : String)
    raise "invalid format" unless match = RAW_RE.match(line)
    new(match[1], match[2], match[3], match[4].split('/'))
  end
end

class CV::CeDict
  def self.load
    @@instance ||= new("var/vhint/lookup/cc_cedict.tsv")
  end

  @trie = ZhTrie(CeTerm).new

  def initialize(file : String)
  end
end
