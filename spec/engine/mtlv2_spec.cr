# require "spec"
# require "../../src/mtlv2/engine"

# ENGINE = MtlV2::Engine.generic_mtl("combine")

# def convert(input : String)
#   ENGINE.cv_plain(input, cap_first: false).to_txt
# end

# describe MtlV2::Engine do
#   files = Dir.glob("spec/engine/cases/**/*.tsv")

#   files.each do |file|
#     suite_name = File.basename(file, ".tsv")
#     next if suite_name.starts_with?('#')

#     if suite_name.starts_with?('!')
#       focus = true
#       suite_name = suite_name[1..]
#     else
#       focus = false
#     end

#     tags = ["mtlv2", suite_name]

#     dir_name = File.basename(File.dirname(file))
#     tags << dir_name == "cases" ? "unsorted" : dir_name

#     # ameba:disable Lint/SpecFocus
#     describe suite_name, focus: focus, tags: tags do
#       lines = File.read_lines(file)

#       lines.each do |line|
#         next if line.empty? || line.starts_with?('#')

#         result = line.split('\t')
#         origin = result.shift

#         it "\"#{origin}\" should translate to #{result}" do
#           result.should contain(convert(origin))
#         end
#       end
#     end
#   end
# end
