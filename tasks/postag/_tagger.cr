require "../../src/mtlv2/*"

class CV::Tagger
  alias Tagging = Hash(PosTag, Int32)

  getter file : String
  getter data = Hash(String, Tagging).new { |h, k| h[k] = Tagging.new(0) }

  def initialize(@file, mode = 1)
    return if mode < 1
    load_file!(@file) if mode > 1 || File.exists?(@file)
  end

  def load_file!(file : String = @file, inferior = false, type = :pku)
    lines = File.read_lines(file)
    lines.each_with_index(1) do |line, idx|
      line = line.strip
      next if line.empty?

      word, tags = line.split('\t', 2)
      next if inferior && @data.has_key?(word)

      tags.split('\t').each do |frag|
        tag, count = frag.split(':', 2)
        postag = to_postag(tag, type)
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
  end

  def add_word(word : String, tag : String, type = :pku)
    postag = to_postag(tag, type)
    @data[word][postag] += 1
  end

  def to_postag(tag : String, type = :pku)
    case type
    when :pfr    then PosTag.from_pfr(tag.downcase)
    when :pku    then PosTag.from_pku(tag)
    when :paddle then PosTag.from_paddle(tag)
    else              PosTag.from_str(tag)
    end
  end

  def save!(file : String = @file, fix_multi = false)
    file_io = File.open(file, "w")

    @data.each do |word, tags|
      file_io << word << '\t'
      tags = tags.to_a.sort_by(&.[1].-)
      tags.map { |k, v| "#{k.to_str}:#{v}" }.join(file_io, "\t")
      file_io << '\n'
    end

    file_io.close
  end
end

tagger = CV::Tagger.new("_db/vpinit/corpus/pfr-tagged.tsv", mode: 0)
tagger.load_file!("_db/vpinit/corpus/tmp/pfr-2014.tsv", type: :pfr)
tagger.load_file!("_db/vpinit/corpus/tmp/pfr-1998.tsv", type: :pfr)
tagger.save!
