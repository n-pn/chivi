require "./_shared"

class VP::CeTerm
  property trad = ""
  property simp = ""

  property pinyin = ""
  property senses = ""

  def initialize(@trad, @simp, @pinyin, @senses)
  end

  RAW_RE = /^(.+?) (.+?) \[(.+?)\] \/.+\/$/

  def self.from_raw(line : String)
    raise "invalid format" unless match = RAW_RE.match(line)
    new(match[1], match[2], match[3], match[4].tr('/', '\t'))
  end
end

class VP::CeDict
  def self.load
    @@instance ||= new("var/vhint/lookup/cc_cedict.tsv")
  end

  @trie = ZhTrie(CeTerm).new

  def initialize(file : String)
  end
end
