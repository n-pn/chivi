require "./_base"

class YS::Ysuser
  include Clear::Model
  self.table = "ysusers"

  primary_key type: :serial
  column y_uid : Int32 # origin yousuu id

  column zname : String
  column vname : String
  # column vslug : String = ""

  column like_count : Int32 = 0
  column star_count : Int32 = 0

  # column list_total : Int32 = 0 # database only
  column list_count : Int32 = 0

  # column crit_total : Int32 = 0 # database only
  column crit_count : Int32 = 0

  # column repl_total : Int32 = 0 # database only
  # column repl_count : Int32 = 0 # database only

  # column info_rtime : Int64 = 0 # database only

  timestamps

  def fix_name! : Nil
    self.vname = SP::MtCore.tl_name(self.zname)
    self.vslug = TextUtil.slugify(vname)
  end

  def self.upsert_sql(fields : Enumerable(String))
    String.build do |stmt|
      stmt << "insert into ysusers ("
      fields.join(stmt, ", ") { |f, io| io << f }
      stmt << ") values ("
      (1..fields.size).join(stmt, ", ") { |ii, io| io << '$' << ii }
      stmt << ") on conflict (y_uid) do update set "
      update_fields = fields.reject(&.== "y_uid")
      update_fields.join(stmt, ", ") { |f, io| io << f << " = excluded." << f }
      stmt << " where ysusers.y_uid = excluded.y_uid"
    end
  end

  def self.update_sql(fields : Enumerable(String))
    String.build do |stmt|
      stmt << "update ysusers set "

      fields.each.with_index(1).join(stmt, ", ") do |(field, index), io|
        io << field << " = $" << index
      end

      stmt << " where y_uid = $" << fields.size + 1
    end
  end

  def self.upsert_info_from_raw_data(data : RawYsUser, rtime : Int64)
    upsert_sql = upsert_sql(RawYsUser::DB_FIELDS)
    PG_DB.exec upsert_sql, *data.db_values(rtime)
    data.user._id
  end

  def self.update_stats_from_raw_data(data : RawBookComments, rtime : Int64)
    return unless data.total > 0

    user_stats_update_sql = update_sql({"crit_total", "crit_rtime"})
    user_stats_update_sql += " and crit_total <= $1"

    y_uid = data.comments.first.user._id

    PG_DB.exec user_stats_update_sql, data.total, rtime, y_uid

    data.total
  end

  ###############

  def self.upsert!(raw_user : EmbedUser)
    find({y_uid: raw_user._id}) || begin
      entry = new

      entry.y_uid = raw_user._id
      entry.zname = raw_user.name
      entry.y_avatar = raw_user.avatar

      entry.tap(&.save!)
    end
  end

  def self.upsert!(y_uid : Int32, zname : String)
    find({y_uid: y_uid}) || begin
      entry = new({y_uid: y_uid, zname: zname}).tap(&.fix_name)
      entry.tap(&.save!)
    end
  end

  def self.preload(ids : Enumerable(Int32))
    ids.empty? ? [] of self : query.where { id.in? ids }
  end
end
