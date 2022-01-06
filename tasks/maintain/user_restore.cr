require "./_shared"

module CV::UserRestore
  extend self

  STR_FIELDS = %w(uname email cpass wtheme)
  INT_FIELDS = %w(karma privi)

  TIME_FIELDS = %w(created_at updated_at privi_until)

  def delete_existing(uname : String)
    return unless old_user = Cvuser.find({uname: uname})
    puts "  delete old record!"
    old_user.delete
  end

  def restore_cvuser(file : String, overwrite : Bool)
    store = Tabkv.new(file)
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

  def restore_ubmemo(user : Cvuser)
    status = Tabkv.new(CV.user_file("memos/" + user.uname + "-status"))
    access = Tabkv.new(CV.user_file("memos/" + user.uname + "-access"))

    status.data.each do |bhash, status_val|
      next unless nvinfo = Nvinfo.load!(bhash)
      access_val = access.get(bhash).not_nil!

      Ubmemo.upsert!(user, nvinfo) do |entry|
        entry.status = Ubmemo.status(status_val[0].to_s)
        entry.locked = status_val[1] == "true"
        entry.atime = status_val[2].to_i64
        entry.created_at = Time.unix(status_val[3].to_i64)
        entry.updated_at = Time.unix(status_val[4].to_i64)

        entry.lr_sname = access_val[0]
        entry.lr_chidx = access_val[1].to_i
        entry.lr_cpart = access_val[2].to_i

        entry.utime = access_val[3].to_i64
        entry.lc_title = access_val[4]
        entry.lc_uslug = access_val[5]
      end
    rescue err
      puts err
    end
  end

  def run!(overwrite = false)
    Dir.glob("#{CVUSER_DIR}/*.tsv").each do |file|
      user = restore_cvuser(file, overwrite: overwrite)
      restore_ubmemo(user)
    end
  end
end

CV::UserRestore.run!(overwrite: ARGV.includes?("--overwrite"))
