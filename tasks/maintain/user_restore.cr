require "./_shared"

module CV::UserRestore
  extend self

  STR_FIELDS = %w(uname email cpass wtheme)
  INT_FIELDS = %w(karma privi tlmode)

  TIME_FIELDS = %w(created_at updated_at privi_until)

  def delete_existing(uname : String)
    return unless old_user = Cvuser.find({uname: uname})
    puts "  delete old record!"
    old_user.delete
  end

  def restore_user(file : String, overwrite : Bool)
    store = TsvStore.new(file)
    uname = File.basename(file, ".tsv")
    user_id = store.ival("id")

    if user = Cvuser.find({id: user_id})
      return unless overwrite
      delete_existing(uname) if uname != user.uname
    else
      delete_existing(uname) if Cvuser.find({uname: uname})
      user = Cvuser.new({id: user_id})
    end

    {% for field in STR_FIELDS %}
      user.{{field.id}} = store.fval({{field}}).not_nil!
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
