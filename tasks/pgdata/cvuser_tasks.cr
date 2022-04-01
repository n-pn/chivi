require "./_shared"

module CV::CvuserTasks
  extend self

  DIR = "var/cvusers"

  def backup
    Cvuser.query.order_by(id: :asc).each do |user|
      user_file = "#{DIR}/#{user.id}.json"
      File.write(user_file, user.to_pretty_json)
      puts "  user <#{cvuser.uname}> saved!".colorize.green
    end
  end

  def restore
    Dir.glob(DIR + ".json").each do |file|
      user_id = File.basename(file, ".json").to_i64
      cvuser = Cvuser.from_json(File.read(file))

      if old_user = Cvuser.find({id: user_id})
        old_user.delete if old_user.uname != cvuser.uname
      else
        Cvuser.find({uname: cvuser.uname}).try { |x| x.delete }
      end

      cvuser.save!
      puts "  user <#{cvuser.uname}> restored!".colorize.green
    end
  end
end

CV::CvuserTasks.backup if ARGV.includes?("backup")
CV::CvuserTasks.restore if ARGV.includes?("restore")
