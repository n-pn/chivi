require "./_shared"

module CV::UserBackup
  extend self

  def user_file(uname : String)
    File.join(CVUSER_DIR, uname.downcase + ".tsv")
  end

  FIELDS = %w(id uname email cpass karma privi wtheme)
  STAMPS = %w(created_at updated_at)

  def save_cvuser(user : Cvuser)
    store = Tabkv.new(user_file(user.uname))

    {% for field in FIELDS %}
      store.set!({{field}}, user.{{field.id}})
    {% end %}

    store.set!("privi_until", user.privi_until.try(&.to_unix))

    {% for field in STAMPS %}
      store.set!({{field}}, user.{{field.id}}.to_unix)
    {% end %}

    store.save!
  end

  def save_ubmemo(user : Cvuser)
    status = Tabkv.new(user_file("memos/" + user.uname + "-status"))
    access = Tabkv.new(user_file("memos/" + user.uname + "-access"))

    Ubmemo.query.where({cvuser_id: user.id}).with_nvinfo.each do |entry|
      value_1 = [entry.status_s, entry.locked, entry.atime, entry.created_at.to_unix, entry.updated_at.to_unix]
      status.set!(entry.nvinfo.bhash, value_1.map(&.to_s))

      value_2 = [entry.lr_sname, entry.lr_chidx, entry.lr_cpart, entry.utime, entry.lc_title, entry.lc_uslug]
      access.set!(entry.nvinfo.bhash, value_2.map(&.to_s))
    end

    status.save!
    access.save!
  end

  def run!(fresh = false)
    FileUtils.rm_rf(CVUSER_DIR) if fresh
    FileUtils.mkdir_p(CVUSER_DIR + "/memos")

    Cvuser.query.order_by(id: :asc).each do |user|
      save_cvuser(user)
      save_ubmemo(user)
    end
  end
end

CV::UserBackup.run!(fresh: ARGV.includes?("--fresh"))
