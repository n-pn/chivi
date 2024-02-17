# require "./chinfo"
# require "compress/zip"
# require "../../_util/text_util"

# class RD::Cztext
#   ZIP_DIR = "/2tb/zroot/ztext"
#   TXT_DIR = "var/texts"

#   getter? has_zip : Bool { File.exists?(@zip_path) }

#   def initialize(@sroot : String)
#     @tmp_path = "#{ZIP_DIR}/#{sroot.sub(/^wn|up|rm/, "")}"
#     @zip_path = "#{@tmp_path}.zip"
#     Dir.mkdir_p(@tmp_path)
#   end

#   def get_ztext(ch_no : Int32, smode : Int32 = 1)
#     return unless self.has_zip?

#     Compress::Zip::File.open(@zip_path) do |zip|
#       return unless entry = zip["#{ch_no}#{smode}.zh"]? || zip["#{ch_no}0.zh"]?

#       ztext = entry.open(&.gets_to_end.gsub("\n\n", '\n'))
#       ztext = ztext.sub(/^\/{3,}.*\n/, "") if ztext.starts_with?('/')
#       ztext
#     end
#   end

#   def save_text!(ch_no : Int32, ztext : String,
#                  chdiv : String = "", smode : Int32 = 0,
#                  zipping : Bool = true)
#     fpath = "#{@tmp_path}/#{ch_no}#{smode}.zh"
#     File.open(fpath, "w") { |f| f << "///" << chdiv << '\n' << ztext }
#     zipping_text!(fpath) if zipping
#   end

#   def zipping_text!(data_path : String = @tmp_path)
#     `zip -rjyoqm '#{@zip_path}' '#{data_path}'`
#     @has_zip = true if $?.success?
#   end

#   ###
# end
