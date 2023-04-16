# require "../shared/bootstrap"
# require "../../src/_init/books/book_info"

# module CV::FixIntros
#   extend self

#   DEBUG = ARGV.includes?("--debug")

#   def fix_intro!(nvinfo : Wninfo, redo = false)
#     unless redo || nvinfo.zintro.empty?
#       bintro = nvinfo.zintro.split("\n")
#       return nvinfo.update(bintro: BookUtil.cv_lines(bintro, nvinfo.dname, :text))
#     end

#     yintro = nil
#     nvinfo.ysbook.try { |x| yintro = x.bintro.split(/\n|\t/) }

#     bintro = sname = nil
#     nvinfo.nvseeds.to_a.sort(&.zseed).each do |nvseed|
#       sintro = nvseed.bintro.split(/\n|\t/)
#       next if sintro.empty? || !decent?(nvseed.sname, sintro, yintro)

#       bintro = sintro
#       sname = nvseed.sname
#       break
#     end

#     if sname != "users" && yintro && yintro.size > 1
#       bintro = yintro
#     else
#       bintro ||= yintro
#     end

#     return unless bintro

#     if DEBUG
#       title = "#{nvinfo.id}-#{nvinfo.bslug}"
#       File.write("tmp/fix-intro.log", "#{title}\n#{bintro.join('\n')}")
#     end

#     nvinfo.set_bintro(bintro, force: true)
#     nvinfo.save!
#   end

#   private def decent?(sname : String, bintro : Array(String), yintro : Array(String)?)
#     case sname
#     when "users", "staff"     then true
#     when "hetushu", "zhwenpg" then !bintro.empty?
#     else
#       return false if bintro.empty?
#       yintro ? yintro.includes?(bintro[0]) : bintro.size > 1
#     end
#   end

#   def load_zinfo(sname : String, snvid : String)
#     BookInfo.new("var/books/infos/#{sname}/#{snvid}.tsv")
#   end

#   def save_current_intro(nvinfo : Wninfo, lines : Array(String))
#     File.open("tmp/fix-intro.log", "w") do |file|
#       file << nvinfo.id << "-" << nvinfo.bslug << '\n'
#       bintro.join(file, '\n')
#     end
#   end

#   def reconvert!(nvinfo : Wninfo)
#     zintro = nvinfo.zintro.lines
#     save_current_intro(nvinfo, zintro) if DEBUG

#     nvinfo.bintro = BookUtil.cv_lines(zintro, nvinfo.dname, :text)
#     nvinfo.save!
#   rescue err
#     puts err
#   end

#   def fix_all!
#     # redo = ARGV.includes?("--redo")
#     count = 0

#     Wninfo.query.order_by(weight: :desc).each do |nvinfo|
#       count += 1
#       puts "- <#{count}> #{nvinfo.bslug}" if count % 1000 == 0

#       # if redo
#       #   fix_intro!(nvinfo)
#       # else
#       reconvert!(nvinfo)
#       # end
#     end
#   end

#   fix_all!
# end
