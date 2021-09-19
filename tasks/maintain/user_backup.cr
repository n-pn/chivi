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

  def run!(fresh = false)
    FileUtils.rm_rf(USER_DIR) if fresh
    FileUtils.mkdir_p(USER_DIR)

    Cvuser.query.order_by(id: :asc).each do |user|
      save_user(user)
    end
  end
end

CV::UserBackup.run!(fresh: ARGV.includes?("--fresh"))
