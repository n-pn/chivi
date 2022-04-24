require "./mt_core"
require "./vp_dict"

module CV::TlUtil
  extend self

  class Trie
    property val : String? = nil
    getter trie = Hash(Char, Trie).new { |h, c| h[c] = Trie.new }
    forward_missing_to @trie
  end

  def load_trie(file : String)
    root = Trie.new

    File.read_lines(file).each do |line|
      next if line.empty?

      key, val = line.split('\t', 2)
      trie = root
      key.chars.reverse_each { |c| trie = trie[c] }
      trie.val = val
    end

    root
  end

  DIR = "var/vpdicts"
  class_getter ptitle : Trie { load_trie("#{DIR}/ptitle.tsv") }
  class_getter naffil : Trie { load_trie("#{DIR}/naffil.tsv") }
  class_getter nother : Trie { load_trie("#{DIR}/nother.tsv") }

  NR_TAGS = ["nr", "n", ""]
  NN_TAGS = ["nn", "ns", "nt", "n", ""]
  NZ_TAGS = ["nz", "n", ""]

  NN_SHORTS = {
    '府' => "? phủ", # '城' => "thành"
    '族' => "? tộc",
    '营' => "doanh ?",
    '朝' => "triều ?",
    '国' => "nước ?",
    '人' => "người ?",
    '地' => "đất ?",
    '市' => "thành phố ?",
    '家' => "? gia",
    '村' => "thôn ?",
  }

  def translate(inp : String, tag : String)
    find_defined(inp, [tag, ""]).try { |x| return x }
    case tag
    when "nr" then convert(inp, self.ptitle, NR_TAGS)
    when "nn"
      return convert(inp, self.naffil, NN_TAGS) if inp.size > 2
      return convert(inp, NN_TAGS) unless val = NN_SHORTS[inp[-1]]?
      val.sub("?", convert(inp[0].to_s))
    when "nz" then convert(inp, self.nother, NZ_TAGS)
    else           convert(inp, [tag])
    end
  end

  def convert(inp : String, trie : Trie, tags : Array(String))
    chars = inp.chars
    output = nil

    while char = chars.pop?
      break unless trie = trie[char]?
      next unless val = trie.val
      output = val.sub("?", convert(chars.join, trie, tags))
      break if chars.empty?
    end

    output || convert(inp, tags.reject("n"))
  end

  def convert(key : String, tags = ["nr"]) : String
    find_defined(key, tags) || TextUtil.titleize(MtCore.cv_hanviet(key, false))
  end

  def find_defined(key : String, tags : Array(String), dict = "regular") : String?
    return key == "段" ? "Đoàn" : nil if key.size == 1

    return unless term = VpDict.load(dict).find(key)
    return unless term.attr.in?(tags) && term._flag == 0
    term.val.first?.try { |x| return x unless x.empty? }
  end

  # pp! translate("马总", "nr")
  # pp! translate("李居士", "nr")
  # pp! translate("黄局长", "nr")
  # pp! translate("暮雪公主", "nr")
  # pp! translate("吴克明", "nr")
  # pp! translate("夏秘书", "nr")
end
