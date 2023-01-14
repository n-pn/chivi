require "spec"
require "../../src/mt_v2/engine"

MTL = M2::Engine.new("combine")

def convert(input : String)
  MTL.cv_plain(input).to_txt(false)
end

DIR = "var/mt_v2/tests"

describe M2::Engine do
  files = Dir.glob("#{DIR}/**/*.tsv")

  files.each do |file|
    suite_name = File.basename(file, ".tsv")
    next if suite_name.starts_with?('#')

    if suite_name.starts_with?('!')
      focus = true
      suite_name = suite_name[1..]
    else
      focus = false
    end

    tags = ["mt_v2", suite_name]

    dir_name = File.basename(File.dirname(file))
    tags << dir_name == "tests" ? "unsorted" : dir_name

    # ameba:disable Lint/SpecFocus
    describe suite_name, focus: focus, tags: tags do
      lines = File.read_lines(file)

      lines.each do |line|
        next if line.empty? || line.starts_with?('#')

        result = line.split('\t')
        origin = result.shift

        it "\"#{origin}\" should translate to #{result}" do
          result.should contain(convert(origin))
        end
      end
    end
  end
end
