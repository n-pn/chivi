require "./_shared"

module CV::UserBackup
  extend self

  def save_cvuser(user : Cvuser)
    user_file = "#{CVUSER_DIR}/#{user.id}.json"
    memo_file = "#{CVUSER_DIR}/memos/#{user.id}.txt"

    File.write(user_file, user.to_pretty_json)

    File.open(memo_file, "w") do |io|
      Ubmemo.query.where({cvuser_id: user.id}).with_nvinfo.each do |entry|
        io << entry.nvinfo.bhash << '\t' << entry.to_json << '\n'
      end
    end
  end

  def run!(fresh = false)
    FileUtils.rm_rf(CVUSER_DIR) if fresh
    FileUtils.mkdir_p(CVUSER_DIR + "/memos")
    Cvuser.query.order_by(id: :asc).each { |user| save_cvuser(user) }
  end
end

CV::UserBackup.run!(fresh: ARGV.includes?("--fresh"))
