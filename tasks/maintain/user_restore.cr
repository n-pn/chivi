require "./_shared"

module CV::UserRestore
  extend self

  def user_file(uname : String)
    File.join(USER_DIR, uname.downcase + ".tsv")
  end

  STR_FIELDS = %w(uname email cpass wtheme)
  INT_FIELDS = %w(karma privi)

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
      return user unless overwrite
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

    puts "  user <#{user.uname}> restored!".colorize.green
    user.tap(&.save!)
  end

  def restore_user_library(user : Cvuser)
    store = TsvStore.new(user_file("library/" + user.uname))
    store.data.each do |bhash, values|
      next unless book = Cvbook.load!(bhash)

      Ubmemo.upsert!(user, book) do |entry|
        entry.status = Ubmemo.status(values[0])
        entry.created_at = Time.unix(values[1].to_i64)
        entry.updated_at = Time.unix(values[1].to_i64)
      end
    rescue err
      puts err
    end
  end

  def restore_user_history(user : Cvuser)
    store = TsvStore.new(user_file("history/" + user.uname))
    store.data.each do |bhash, values|
      next unless book = Cvbook.load!(bhash)

      Ubmemo.upsert!(user, book) do |entry|
        entry.bumped = values[2].to_i64

        entry.lr_zseed = Zhseed.index(values[0])
        entry.lr_chidx = values[1].to_i

        entry.lc_title = values[3]
        entry.lc_uslug = values[4]
      end
    rescue err
      puts err
    end
  end

  def run!(overwrite = false)
    Dir.glob("#{USER_DIR}/*.tsv").each do |file|
      user = restore_user(file, overwrite: overwrite)
      restore_user_library(user)
      restore_user_history(user)
    end
  end
end

CV::UserRestore.run!(overwrite: ARGV.includes?("--overwrite"))
