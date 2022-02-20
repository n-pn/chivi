require "./_shared"

module CV::UserRestore
  extend self

  def restore_cvuser(file : String, overwrite : Bool)
    user_id = File.basename(file, ".json").to_i64
    cvuser = Cvuser.from_json(File.read(file))

    if old_user = Cvuser.find({id: user_id})
      return old_user unless overwrite
      old_user.delete if old_user.uname != cvuser.uname
    else
      Cvuser.find({uname: cvuser.uname}).try { |x| x.delete }
    end

    cvuser.save!
    puts "  user <#{cvuser.uname}> restored!".colorize.green

    memo_file = "#{CVUSER_DIR}/memos/#{cvuser.id}.txt"

    File.read_lines(memo_file).each do |line|
      bhash, json = line.split('\t', 2)
      next unless nvinfo = Nvinfo.load!(bhash)

      ubmemo = Ubmemo.from_json(json)
      ubmemo.nvinfo_id = nvinfo.id
      ubmemo.save!
    rescue err
      puts err
    end
  end

  def run!(overwrite = false)
    Dir.glob("#{CVUSER_DIR}/*.json").each do |file|
      restore_cvuser(file, overwrite: overwrite)
    end
  end
end

CV::UserRestore.run!(overwrite: ARGV.includes?("--overwrite"))
