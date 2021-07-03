require "../../src/mtlv2/*"

class CV::Tagger
  alias Tagging = Hash(PosTag, Int32)

  getter file : String
  getter data = Hash(String, Tagging).new { |h, k| h[k] = Tagging.new(0) }

  def initialize(@file, @type = :pku, mode = 1)
    return if mode < 1
    load_file!(@file) if mode > 1 || File.exists?(@file)
  end

  def load_file!(file : String = @file, skip_existing = false)
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

    puts "- file #{file} loaded!"
  end

  def add_word(word : String, tag : String)
    postag = to_postag(tag)
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

    @data.each do |word, tags|
      file_io << word << '\t'

      tags = tags.to_a.sort_by(&.[1].-)
      line = tags.map { |k, v| "#{k.to_str}:#{v}" }.join(file_io, "\t")
      file_io << '\n'
    end

    file_io.close
    puts "- file #{file} saved!"
  end
end

class CV::Merger
  alias Merging = Tuple(String, String)

  getter file : String
  getter data = Hash(String, Merging).new

  def initialize(@file, mode = 1)
    return if mode < 1
    load_file!(@file) if mode > 1 || File.exists?(@file)
  end

  def load_file!(file = @file, skip_existing = true)
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

    puts "- file #{file} loaded!"
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
