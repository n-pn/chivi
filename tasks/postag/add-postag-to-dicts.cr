require "../../src/libcv/vdict"
require "../../src/mtlv2/vp_dict"

private module Utils
  extend self

  def load_postag(file : String, hash = {} of String => String)
    return hash unless File.exists?(file)

    File.each_line(file) do |line|
      frags = line.split('\t')
      next if frags.size < 2
      word, tag = frags
      hash[word] ||= tag.split(":").first
    end

    puts " - <postag> #{file} loaded, entries: #{hash.size}"
    hash
  end

  DIR = "_db/vpinit/corpus"

  @@cache = {} of String => Hash(String, String)

  def postag_map(file : String)
    @@cache[file] ||= load_postag("#{DIR}/#{file}")
  end

  # class_getter postag : Hash(String, String) do
  #   hash = load_postag("#{DIR}/pfrtag.tsv")
  #   load_postag("#{DIR}/pkuseg-words.tsv", hash)
  # end

  def get_postag(word : String, book : String = "")
    case
    when tag = postag_map("pkuseg/#{book}.tsv")[word]? then tag
    when tag = postag_map("pfrtag.tsv")[word]?         then tag
    when tag = postag_map("pkuseg-words.tsv")[word]?   then tag
    else                                                    ""
    end
  end

  def get_weight(prio : Int32)
    case prio
    when 0 then 2
    when 1 then 3
    when 2 then 4
    else        prio
    end
  end
end

def add_postag(old_name : String, new_name = old_name)
  old_dict = CV::Vdict.load(old_name)
  new_dict = CV::VpDict.load(new_name, reset: true)

  old_dict.each(full: true) do |old_term|
    tag = Utils.get_postag(old_term.key, new_name)

    wgt = Utils.get_weight(old_term.prio)
    ext = wgt == 3 ? tag : "#{tag} #{wgt}"
    new_term = new_dict.new_term(
      old_term.key, old_term.vals, ext,
      old_term.mtime, old_term.uname, old_term.power)

    new_dict.set(new_term)
  end

  new_dict.save!(prune: false)
end

add_postag("regular")
add_postag("various")

CV::Vdict.udicts.each { |udict| add_postag(udict) }
