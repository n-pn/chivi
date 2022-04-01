require "./_shared"

module CV::CvuserTasks
  extend self

  DIR = "var/cvusers"

  def backup
    Cvuser.query.order_by(id: :asc).each do |user|
      user_file = "#{DIR}/#{user.id}.json"
      File.write(user_file, user.to_pretty_json)
      puts "  user <#{user.uname}> saved!".colorize.green
    end
  end

  def restore
    Dir.glob(File.join(DIR, "*.json")).each_with_index do |file, idx|
      user = Cvuser.from_json(File.read(file))

      if old_user = Cvuser.find({id: user.id})
        old_user.delete
      else
        Cvuser.find({uname: user.uname}).try { |x| x.delete }
      end

      user.save!
      puts "- #{idx}: [#{user.id}] user <#{user.uname}> restored!".colorize.green
    end

    Clear::SQL.execute <<-SQL
    SELECT pg_catalog.setval(pg_get_serial_sequence('cvusers', 'id'), MAX(id)) FROM cvusers;
  SQL
  end
end

CV::CvuserTasks.backup if ARGV.includes?("backup")
CV::CvuserTasks.restore if ARGV.includes?("restore")
