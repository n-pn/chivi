require "../../src/libcv/*"

struct CV::PosTag
  def self.from_pfr(tag : ::String) : self
    case tag
    when "nnt", "nis", "nnd", "ntc", "nf", "nhd", "nit", "nhm", "nmc", "nba",
         "gb", "gc", "gg", "gi", "gm", "gp"
      new(Tag::Noun)
    when "nto", "ntu", "ntcb", "nth", "ntcf", "ntch", "nts"
      new(Tag::Norg)
    when "nh" then new(Tag::Nper)
    when "nx" then new(Tag::Nother)
    when "bg" then new(Tag::Modifier)
    when "rg" then new(Tag::ProPer)
    when "ul" then new(Tag::Ule)
    when "uj" then new(Tag::Ude1)
    when "uv" then new(Tag::Ude2)
    when "ud" then new(Tag::Ude3)
    when "uz" then new(Tag::Uzhe)
    else           from_pku(tag)
    end
  end

  def self.from_pku(tag : ::String) : self
    # nr1 汉语姓氏
    # nr2 汉语名字
    # nrj 日语人名
    # nrf 音译人名
    # nsf 音译地名
    # rzt 时间指示代词
    # rzs 处所指示代词
    # rzv 谓词性指示代词
    # ryt 时间疑问代词
    # rys 处所疑问代词
    # ryv 谓词性疑问代词
    # dg adverbial morpheme
    # dl adverbial formulaic expression
    case tag
    when "nr1", "nr2", "nrj", "nrf" then new(Tag::Nper)
    when "nsf"                      then new(Tag::Nloc)
    when "nx"                       then new(Tag::Nother)
    when "rzt", "rzs", "rzv"        then new(Tag::ProDem)
    when "ryt", "rys", "ryv"        then new(Tag::ProInt)
    when "dl", "dg"                 then new(Tag::Adverb)
    else                                 from_str(tag)
    end
  end

  def self.from_paddle(tag : ::String) : self
    case tag
    # Paddle convention
    when "PER"  then new(Tag::Nper)
    when "LOC"  then new(Tag::Nloc)
    when "ORG"  then new(Tag::Norg)
    when "TIME" then new(Tag::Time)
    else             from_str(tag)
    end
  end
end

class CV::Tagsum
  alias Tagging = Hash(PosTag, Int32)

  getter file : String
  getter data = Hash(String, Tagging).new { |h, k| h[k] = Tagging.new(0) }
  forward_missing_to @data

  def initialize(@file, @type = :pku, mode = 1)
    return if mode < 1
    load_tagsum!(@file) if mode > 1 || File.exists?(@file)
  end

  def load_tagsum!(file : String = @file, skip_existing = false)
    lines = File.read_lines(file)
    lines.each_with_index(1) do |line, idx|
      line = line.strip
      next if line.empty?

      word, tags = line.split('\t', 2)
      next if skip_existing && @data.has_key?(word)

      tags.split('\t').each do |frag|
        tag, count = frag.split(':', 2)
        postag = to_postag(tag)
        count = count.to_i

        if postag == PosTag::None && count > 1
          puts "- #{File.basename(file)}: Unknown tag: '#{tag}:#{count}' for '#{word}'"
          next
        end

        @data[word][postag] += count
      end
    rescue err
      puts "<#{file}:#{idx}> error: \n  #{err.message}"
    end

    puts "- <tagsum> file #{file} loaded, entries: #{lines.size}!"
  end

  def load_postag!(file : String)
    File.each_line(file) do |line|
      add_postag_line(line)
    end
  end

  def add_postag_line(line : String)
    parts = line.split(" ")
    parts.each do |part|
      vals = part.split('/')
      next if vals.size != 2

      word, tag = vals
      add_postag(word, tag)
    rescue err
      puts "error: #{err.message} for [#{part}]"
    end
  end

  def add_postag(word : String, tag : String)
    postag = to_postag(tag)
    raise "unknown tag #{tag}" if postag == PosTag::None
    @data[word][postag] += 1
  end

  def to_postag(tag : String)
    case @type
    when :pfr    then PosTag.from_pfr(tag.downcase)
    when :pku    then PosTag.from_pku(tag)
    when :paddle then PosTag.from_paddle(tag)
    else              PosTag.from_str(tag)
    end
  end

  def save!(file : String = @file) : Nil
    file_io = File.open(file, "w")

    output = @data.map do |word, tags|
      {word, tags.to_a.sort_by(&.[1].-)}
    end

    output.sort_by! { |_, tags| -tags[0][1] }

    output.each do |word, tags|
      file_io << word
      tags.each { |k, v| file_io << '\t' << k.to_str << ':' << v }
      file_io << '\n'
    end

    file_io.close
    puts "- <tagsum> file #{file} saved, entries: #{output.size}"
  end
end

class CV::Merger
  alias Merging = Tuple(String, String)

  getter file : String
  getter ftab : String
  getter data = Hash(String, Merging).new
  forward_missing_to @data

  def initialize(@file, mode = 1)
    @ftab = @file.sub(".tsv", ".fix.tsv")

    return if mode < 1
    load_merger!(@ftab) if mode > 1 || File.exists?(@ftab)
    load_merger!(@file) if mode > 1 || File.exists?(@file)
  end

  def load_merger!(file = @file, skip_existing = true)
    lines = File.read_lines(file)
    lines.each_with_index(1) do |line, idx|
      line = line.strip
      next if line.empty?

      key, tag, org = line.split('\t')
      next if skip_existing && @data.has_key?(key)
      @data[key] = {tag, org}
    rescue err
      puts "<#{file}:#{idx}> error: \n  #{err.message}"
    end

    puts "- <postag> file #{file} loaded, entries: #{lines.size}".colorize.blue
  end

  def add_tagsum!(file : String,
                  label = File.basename(file, ".tsv"),
                  skip_existing = true)
    tagsum = Tagsum.new(file, mode: 2)
    tagsum.each do |word, vals|
      next if skip_existing && @data.has_key?(word)
      next unless postag = extract_tag(word, vals, label)

      @data[word] = {postag.to_str, label}
      next unless vals.first_value >= 100

      File.open(@ftab.sub("fix", "top"), "a") do |io|
        {word, postag.to_str, label}.join(io, '\t')
        io << '\n'
      end
    rescue err
      puts err.colorize.red
    end
  end

  def extract_tag(word : String, vals : Hash(PosTag, Int32), label : String) : PosTag?
    first_tag = vals.first_key
    max_count = vals.first_value

    return nil if max_count < 5

    min_count = max_count > 10 ? 5 : max_count - 5
    min_count = 2 if min_count < 2

    vals = vals.reject { |t, c| c < min_count }

    return first_tag if vals.size < 2

    prompt_tag(word, vals).tap do |postag|
      File.open(@ftab, "a") do |io|
        {word, postag.to_str, label}.join(io, '\t')
        io << '\n'
      end
    end
  end

  def prompt_tag(word : String, vals : Hash(PosTag, Int32)) : PosTag
    label = vals.map { |k, v| "#{k.to_str}:#{v}" }

    puts "\nResolve: #{word} #{label}".colorize.yellow

    if is_veno?(vals)
      puts "- auto choose tag: <vn> ".colorize.green
      return PosTag::Veno
    end

    print "- choice: "
    case tag = gets.not_nil!
    when .empty?
      vals.first_key
    else
      postag = PosTag.from_str(tag)
      raise "Unknown postag <#{tag}>" if postag == PosTag::None
      postag
    end
  end

  def is_veno?(vals) : Bool
    return false unless vals.has_key?(PosTag::Veno)
    vals.each_key do |postag|
      case postag
      when .veno?, .verb?, .vintr?, .vead?
        next
      else
        return false
      end
    end

    true
  end

  def save!(file = @file) : Nil
    file_io = File.open(file, "w")

    @data.each do |key, (tag, org)|
      {key, tag, org}.join(file_io, '\t')
      file_io << '\n'
    end

    file_io.close
    puts "- file #{file} saved!"
  end
end

# tagger = CV::Tagger.new("_db/vpinit/corpus/pfr14.tsv", mode: 0, type: :pfr)
# tagger.load_file!("_db/vpinit/corpus/tmp/pfr-2014.tsv")
# tagger.save!

# tagger = CV::Tagger.new("_db/vpinit/corpus/pfr98.tsv", mode: 0, type: :pfr)
# tagger.load_file!("_db/vpinit/corpus/tmp/pfr-1998.tsv")
# tagger.save!
