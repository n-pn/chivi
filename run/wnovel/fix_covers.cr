require "../../src/_data/wnovel/wninfo"

nvinfos = CV::Wninfo.query
  .where("scover <> ''")
  .where("bcover = ''")
  .to_a.shuffle!

w_size = 16
q_size = nvinfos.size

workers = Channel({CV::Wninfo, Int32}).new(q_size)
results = Channel(Nil).new(w_size)

w_size.times do
  spawn do
    loop do
      wnovel, idx = workers.receive
      wnovel.cache_cover(persist: true)
      puts "- #{idx}/#{q_size} <#{wnovel.id}-#{wnovel.vname.colorize.cyan}> #{wnovel.scover.colorize.blue} => [#{wnovel.bcover.colorize.yellow}]"
    rescue err
      Log.error(exception: err) { err.message.colorize.red }
    ensure
      results.send(nil)
    end
  end
end

nvinfos.each_with_index(1) { |nvinfo, idx| workers.send({nvinfo, idx}) }
q_size.times { results.receive }
