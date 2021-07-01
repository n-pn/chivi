# origin: http://www.zd9999.com/ci/
# source: https://github.com/pwxcoo/chinese-xinhua
# convert json to tsv

require "json"

class CV::Idiom
  include JSON::Serializable

  property word : String

  property pinyin : String

  @[JSON::Field(key: "explanation")]
  property gloss : String
end

class CV::Word
  include JSON::Serializable

  @[JSON::Field(key: "ci")]
  property word : String

  @[JSON::Field(key: "explanation")]
  property gloss : String
end

class CV::Char
  include JSON::Serializable

  property word : String

  @[JSON::Field(key: "oldword")]
  property trad : String

  property pinyin : String

  @[JSON::Field(key: "explanation")]
  property gloss : String
end

INP = "_db/.miscs/Chinese NLP/chinese-xinhua-master/data"
OUT = "db/corpus"

def inp_path(file : String)
  File.join(INP, file)
end

def out_path(file : String)
  File.join(OUT, file)
end

def extract_idioms
  inp_file = inp_path("idiom.json")
  inp_data = Array(CV::Idiom).from_json File.read(inp_file)

  out_data = [] of String
  File.open(out_path("xinhua-idioms.tsv"), "w") do |f|
    inp_data.each do |input|
      out_data << input.word
      {input.word, input.pinyin, input.gloss.gsub("\n", "  ")}.join(f, '\t')
      f.puts
    end
  end

  out_data
end

def extract_words
  inp_file = inp_path("ci.json")
  inp_data = Array(CV::Word).from_json File.read(inp_file)

  out_data = [] of String
  File.open(out_path("xinhua-words.tsv"), "w") do |f|
    inp_data.each do |input|
      out_data << input.word
      {input.word, input.gloss.gsub("\n", "  ")}.join(f, '\t')
      f.puts
    end
  end

  out_data
end

def extract_chars
  inp_file = inp_path("word.json")
  inp_data = Array(CV::Char).from_json File.read(inp_file)

  out_data = [] of String
  File.open(out_path("xinhua-chars.tsv"), "w") do |f|
    inp_data.each do |input|
      out_data << input.word
      {input.word, input.pinyin, input.trad, input.gloss.gsub("\n", "  ")}.join(f, '\t')
      f.puts
    end
  end

  out_data
end

xinhua = [] of String
xinhua.concat extract_idioms
xinhua.concat extract_words
xinhua.concat extract_chars

File.write(out_path("xinhua.txt"), xinhua.join("\n"))
