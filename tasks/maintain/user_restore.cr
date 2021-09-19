require "./_shared"

module CV::UserRestore
  extend self

  STR_FIELDS = %w(uname email cpass wtheme)
  INT_FIELDS = %w(karma privi tlmode)

  TIME_FIELDS = %w(created_at updated_at privi_until)

  def restore_user(file : String, overwrite : Bool)
    store = TsvStore.new(file)
    user_id = store.ival("id")
    if user = Cvuser.find({id: user_id})
      return unless overwrite
    else
      user = Cvuser.new({id: user_id})
    end

    {% for field in STR_FIELDS %}
      user.{{field.id}} = store.fval({{field}}) || ""
    {% end %}

    {% for field in INT_FIELDS %}
      user.{{field.id}} = store.ival({{field}})
    {% end %}

    {% for field in TIME_FIELDS %}
      user.{{field.id}} = Time.unix(store.ival_64({{field}}))
    {% end %}

    user.save!
    puts "  user <#{user.uname}> restored!".colorize.green
  end

  def run!(overwrite = false)
    Dir.glob("#{USER_DIR}/*.tsv").each do |file|
      restore_user(file, overwrite: overwrite)
    end
  end
end

CV::UserRestore.run!(overwrite: ARGV.includes?("--overwrite"))
