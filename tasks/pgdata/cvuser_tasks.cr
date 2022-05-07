require "../bootstrap"

module CV::CvuserTasks
  extend self

  DIR = "var/pg_data/cvusers"

  def backup
    Cvuser.query.order_by(id: :asc).each do |user|
      user_file = "#{DIR}/#{user.id}.json"
      File.write(user_file, user.to_pretty_json)
      puts "  user <#{user.uname}> saved!".colorize.green
    end
  end

  DELETE_OLD = ARGV.includes?("--delete-old")

  def restore
    Dir.glob(File.join(DIR, "*.json")).each_with_index do |file, idx|
      user = Cvuser.from_json(File.read(file))

      if DELETE_OLD
        Cvuser.find({id: user.id}).try(&.delete)
        Cvuser.find({uname: user.uname}).try(&.delete)
      end

      user.save!
      puts "- #{idx}: [#{user.id}] user <#{user.uname}> restored!".colorize.green
    rescue err
      puts err.colorize.red
    end

    Clear::SQL.execute <<-SQL
    SELECT pg_catalog.setval(pg_get_serial_sequence('cvusers', 'id'), MAX(id)) FROM cvusers;
  SQL
  end

  backup if ARGV.includes?("backup")
  restore if ARGV.includes?("restore")
end
