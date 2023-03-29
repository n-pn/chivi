require "../../src/_data/wnovel/bcover"

# struct CoverInfo
#   getter link : String = ""
#   getter name : String = ""

#   getter format : String = ""

#   getter width : Int32 = 0
#   getter? on_r2 : Bool = false

#   def initialize(path : String)
#     File.each_line(path) do |line|
#       next if line.blank?
#       key, val = line.strip.split('\t')

#       case key
#       when "link"   then @link = val
#       when "name"   then @name = val
#       when "format" then @format = val
#       when "width"  then @width = val.to_i
#       when "on_r2"  then @on_r2 = val == "t"
#       end
#     end
#   end
# end

# Dir.glob("#{CV::Bcover::DIR}/*.tsv") do |file|
#   rinfo = CoverInfo.new(file)
#   cover = CV::Bcover.load(rinfo.link, rinfo.name)

#   cover.name = rinfo.name
#   cover.ext = rinfo.format

#   cover.width = rinfo.width
#   cover.mtime = File.info(file).modification_time.to_unix

#   webp_path = cover.image_path(".webp")
#   orig_path = cover.image_path

#   if File.file?(webp_path)
#     cover.state = rinfo.on_r2? ? 6_i16 : 4_i16
#   elsif File.file?(orig_path)
#     cover.state = 3_i16
#   else
#     cover.state = 1_i16
#   end

#   puts "#{cover.link} updated, new state: #{cover.state}"
#   cover.save!
# end

CV::Bcover.query.where("state < 2").each do |cover|
  cover.name = CV::Bcover.gen_name(cover.link) if cover.name.blank?

  orig_path = cover.image_path
  webp_path = cover.image_path(".webp")

  if File.file?(webp_path)
    cover.state = 4_i16
    cover.mtime = File.info(webp_path).modification_time.to_unix
  elsif File.file?(orig_path)
    cover.state = 3_i16
    cover.mtime = File.info(orig_path).modification_time.to_unix
  end

  puts "#{cover.link} updated, new state: #{cover.state}"
  cover.save!
end
