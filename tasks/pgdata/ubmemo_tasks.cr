require "./_shared"

module CV::UbmemoTasks
  extend self

  DIR = "var/ubmemos"

  def backup
    Ubmemo.query.order_by(id: :asc).each do |user|
      file = "#{DIR}/#{user.id}.txt"

      File.open(file, "w") do |io|
        Ubmemo.query.where({cvuser_id: user.id}).with_nvinfo.each do |entry|
          io << entry.nvinfo.bhash << '\t' << entry.to_json << '\n'
        end
      end
      puts "  user <#{cvuser.uname}> saved!".colorize.green
    end
  end

  def restore
    Dir.glob(DIR + ".txt").each do |file|
      File.read_lines(file).each do |line|
        bhash, json = line.split('\t', 2)
        next unless nvinfo = Nvinfo.load!(bhash)

        ubmemo = Ubmemo.from_json(json)
        ubmemo.nvinfo_id = nvinfo.id
        ubmemo.save!
      rescue err
        puts err
      end

      user_id = File.basename(file, ".txt").to_i64
      puts "  user <#{user_id}> restored!".colorize.green
    end
  end
end

CV::UbmemoTasks.backup if ARGV.includes?("backup")
CV::UbmemoTasks.restore if ARGV.includes?("restore")
