require "../../src/mt_ai/core/*"
require "yaml"

struct Case
  getter con : String
  getter txt : String = ""
  getter alt : String = ""
  getter focus : Bool = false
  getter pdict : String = ""
  include YAML::Serializable

  def self.from_file(path : String)
    File.open(path, "r") { |file| Array(self).from_yaml(file) }
  end

  def call_test!
    data = MT::AiData.parse_con_data(@con)
    data.root.tl_phrase!(dict: MT::AiDict.load(@pdict))

    puts "--------------------------------".colorize.dark_gray
    puts data.zstr.colorize.cyan
    puts "--------------------------------".colorize.dark_gray
    puts MT::QtCore.tl_hvword(data.zstr, true).colorize.light_gray
    puts "--------------------------------".colorize.dark_gray
    data.root.inspect(STDOUT)
    puts nil
    puts "--------------------------------".colorize.dark_gray
    puts data.to_txt.colorize.yellow
  end
end

def test_case(file_path : String, focus_only = false)
  puts file_path
  cases = Case.from_file(file_path)
  cases.select!(&.focus) if focus_only
  cases.each(&.call_test!)
end

tspan = Time.measure do
  files = ARGV.reject!(&.starts_with?('-'))
  files = Dir.glob("spec/mt_ai/cases/**/*.yml") if files.empty?

  focus_only = ARGV.includes?("--focus")

  files.each do |file|
    test_case(file, focus_only)
  end
end

puts "--------------------------------".colorize.dark_gray
puts "Total time used (including loading dicts): #{(tspan).total_milliseconds.round}ms".colorize.red
