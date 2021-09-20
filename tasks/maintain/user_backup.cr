require "./_shared"

module CV::UserBackup
  extend self

  def user_file(uname : String)
    File.join(USER_DIR, uname.downcase + ".tsv")
  end

  FIELDS = %w(id uname email cpass karma privi wtheme tlmode)

  TIMESTAMPS = %w(created_at updated_at)

  def save_user(user : Cvuser)
    store = TsvStore.new(user_file(user.uname))

    {% for field in FIELDS %}
      store.set!({{field}}, user.{{field.id}})
    {% end %}

    store.set!("privi_until", user.privi_until.try(&.to_unix))

    {% for field in TIMESTAMPS %}
      store.set!({{field}}, user.{{field.id}}.to_unix)
    {% end %}

    store.save!
  end

  def save_user_library(user : Cvuser)
    store = TsvStore.new(user_file("library/" + user.uname))

    Ubmark.query.where({cvuser_id: user.id}).with_cvbook.each do |entry|
      value = [entry.label, entry.created_at.to_unix, entry.updated_at.to_unix]
      store.set!(entry.cvbook.bhash, value.map(&.to_s))
    end

    store.save!
  end

  def save_user_history(user : Cvuser)
    store = TsvStore.new(user_file("history/" + user.uname))

    Ubview.query.where({cvuser_id: user.id}).with_cvbook.each do |entry|
      value = [entry.sname, entry.chidx, entry.bumped, entry.ch_title, entry.ch_label, entry.ch_uslug]
      store.set!(entry.cvbook.bhash, value.map(&.to_s))
    end

    store.save!
  end

  def run!(fresh = false)
    FileUtils.rm_rf(USER_DIR) if fresh
    FileUtils.mkdir_p(USER_DIR + "/library")
    FileUtils.mkdir_p(USER_DIR + "/history")

    Cvuser.query.order_by(id: :asc).each do |user|
      save_user(user)
      save_user_library(user)
      save_user_history(user)
    end
  end
end

CV::UserBackup.run!(fresh: ARGV.includes?("--fresh"))
