require "colorize"

class Parser
  @data = Hash(String, Hash(String, Int32)).new do |h, k|
    h[k] = Hash(String, Int32).new(0)
  end

  def read_file!(inp_file : String, delimit = "  ")
    puts "- read: #{inp_file}"

    lines = File.read_lines(inp_file)

    lines.each_with_index(1) do |line, idx|
      if idx % 1000 == 0
        puts "-- reading #{idx}/#{lines.size}"
      end

      tokens = line.strip.split(delimit)
      next if tokens.empty?

      parse_tokens(tokens)
    rescue err
      puts "-" * 10
      puts [idx, err.message].join('\t').colorize.red
      puts tokens.try(&.join('\t').colorize.cyan)
      puts "-" * 10
      exit 0
    end
  end

  GROUP_START_RE = /^\[[^\/]/

  def parse_tokens(tokens : Array(String))
    i = tokens[0].starts_with?("199801") ? 1 : 0
    while token = tokens[i]?
      i += 1

      next if token.blank?

      if token.matches?(GROUP_START_RE)
        token = token[1..]
        acc, _ = add_word(token)

        while token = tokens[i]?
          i += 1

          next if token.blank?

          break if token.includes?(']')
          word, _ = add_word(token)
          acc += word
        end

        next unless token

        token, tag = token.split(']', 2)
        word, _ = add_word(token)

        acc += word

        tag = tag[1..] if tag.starts_with?('/')

        @data[acc][tag] += 1
      else
        add_word(token)
      end
    end
  end

  def add_word(token : String) : Tuple(String, String)
    return {token.sub("/w", ""), "w"} if token.ends_with?("/w")
    return {token.sub("/m", ""), "m"} if token.ends_with?("/m")

    word, tag = token.split('/', 2)
    raise "malformed tag" if tag =~ /[^\w\d]/

    @data[word][tag] += 1
    {word, tag}
  rescue err
    raise "error for [#{token}]: #{err.message}"
  end

  def each
    @data.each do |word, tags|
      yield word, tags.to_a.sort_by(&.[1].-)
    end
  end

  def save!(out_file : String, sort = true)
    puts "- save to: #{out_file}"

    res = @data.to_a
    res.sort_by! { |_, tags| -tags.values.sum } if sort

    File.open(out_file, "w") do |f|
      res.each do |word, tags|
        f << word

        ary = tags.to_a.sort_by { |_, c| -c }.each do |tag, count|
          f << '\t' << tag << ':' << count
        end

        f << "\n"
      end
    end
  end

  def reset!
    @data.clear
  end
end

def fix_file(file : String, word : String)
  text = File.read(file)
  text = text.gsub(word, "#{word}/w ").gsub("/w /w", "/w")
  File.write(file, text)
end

INP = "_db/.miscs/Chinese NLP"

# fix_file("#{INP}/2014_corpus.txt", ",")

parser = Parser.new

# parser.read_file!("#{INP}/词性标注@人民日报199801.txt")
# parser.save!("db/corpus/pfr-1998.tsv")

# parser.reset!
parser.read_file!("#{INP}/2014_corpus.txt", " ")
parser.save!("db/corpus/pfr-2014.tsv")
