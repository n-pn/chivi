require "../shared/seed_util"

DEBUG = ARGV.includes?("debug")

CV::Yscrit.query.order_by(id: :asc).with_nvinfo.each_with_cursor(10) do |yscrit|
  if DEBUG
    File.open("tmp/yscrit-err.log", "w") do |io|
      io.puts yscrit.nvinfo.bhash
      yscrit.zhtext.join(io, '\n')
    end
  end

  vhtml = CV::SeedUtil.cv_ztext(yscrit.zhtext, yscrit.nvinfo.bhash)
  yscrit.update!({vhtml: vhtml})
rescue err
  File.open("tmp/yscrit-#{yscrit.id}.log", "w") do |io|
    io.puts yscrit.nvinfo.bhash
    yscrit.zhtext.join(io, '\n')
    io.puts "----"
    err.inspect_with_backtrace(io)
  end
end
