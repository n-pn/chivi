require "./_shared"

module CV::UbmemoTasks
  extend self

  DIR = "var/ubmemos"

  def backup
    Cvuser.query.order_by(id: :asc).each do |user|
      file = "#{DIR}/#{user.id}.txt"

      File.open(file, "w") do |io|
        Ubmemo.query.where({cvuser_id: user.id}).with_nvinfo.each do |entry|
          io << entry.nvinfo.bhash << '\t' << entry.to_json << '\n'
        end
      end
      puts "  user <#{user.uname}> saved!".colorize.green
    end
  end

  def restore
    Dir.glob(DIR + "/*.txt").each do |file|
      File.read_lines(file).each do |line|
        bhash, json = line.split('\t', 2)
        unless nvinfo = Nvinfo.find({bhash: bhash})
          puts " book: #{bhash} not found!!"
          next
        end

        ubmemo = Ubmemo.from_json(json)
        Ubmemo.find({id: ubmemo.id}).try(&.delete)

        ubmemo.nvinfo_id = nvinfo.id
        ubmemo.save!
      rescue err
        puts err
      end

      user_id = File.basename(file, ".txt").to_i64
      puts "  user <#{user_id}> restored!".colorize.green
    end

    Clear::SQL.execute <<-SQL
      SELECT pg_catalog.setval(pg_get_serial_sequence('ubmemos', 'id'), MAX(id)) FROM ubmemos;
    SQL
  end
end

CV::UbmemoTasks.backup if ARGV.includes?("backup")
CV::UbmemoTasks.restore if ARGV.includes?("restore")
