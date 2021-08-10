require "file_utils"
require "compress/zip"

class CV::SplitText
  DIR = "_db/.keeps/manual"

  class Chap
    property label
    property lines = [] of String

    def title : String
      lines.first? || ""
    end

    def initialize(@label = "")
    end
  end

  getter chaps = [] of Chap

  def initialize(@inp_file : String, @bhash = inp_file)
    @input = File.read_lines("#{DIR}/#{@inp_file}.txt")
  end

  def split_by_title_regex(regex = /^\s*【第[\d一]+章】/, label = "")
    @chaps = [Chap.new(label)]

    @input.each do |line|
      @chaps << Chap.new(label) if regex.match(line)
      @chaps.last.lines << line.strip
    end

    @chaps.shift if @chaps.first.lines.empty?

    puts "\nsplit #{@inp_file} by regex #{regex.to_s}:"
    puts "- total chaps: #{@chaps.size}"
    puts "-" * 8
    @chaps.first(4).each do |chap|
      puts chap.title
    end
    puts "-" * 8

    @chaps.last(4).each do |chap|
      puts chap.title
    end
  end

  def save!
    out_dir = "_db/chseed/chivi/#{@bhash}"
    FileUtils.mkdir_p(out_dir)

    index = [] of String

    chaps.each_slice(100).with_index do |slice, idx|
      out_zip = File.join(out_dir, idx.to_s.rjust(3, '0') + ".zip")

      File.open(out_zip, "w") do |file|
        Compress::Zip::Writer.open(file) do |zip|
          slice.each_with_index(1) do |chap, chidx|
            chidx = chidx + 100 * idx
            schid = chidx.to_s.rjust(4, '0')

            zip.add("#{schid}.txt", chap.lines.join('\n'))
            index << [schid, chap.title, chap.label].join('\t')
          end
        end
      end
    end

    File.write("#{out_dir}/_id.tsv", index.join('\n'))
  end
end

# splitter = CV::SplitText.new("van-de-muoi-muoi-1850", "baac9fvq")
# splitter.tap(&.split_by_title_regex).save!

x = CV::SplitText.new("h0q4vtmp")
x.tap(&.split_by_title_regex(/^第/)).save!
