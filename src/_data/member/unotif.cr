require "crorm"
require "../_data"
require "../../_util/hash_util"

class CV::Unotif
  include Crorm::Model
  @@table = "unotifs"
  @@db : DB::Database = PGDB

  field id : Int32, primary: true
  field viuser_id : Int32

  field content : String = ""
  field details : String = ""
  field link_to : String = ""

  field _undo_tag_ : String = ""

  field reached_at : Time? = nil
  field created_at : Time = Time.utc

  def initialize(@viuser_id, @content, @details, @link_to, @_undo_tag_ = "")
  end

  def create!(db = @@db)
    stmt = <<-SQL
      insert into #{@@table}(viuser_id, content, details, link_to, _undo_tag_, created_at)
      values ($1, $2, $3, $4, $5, $6)
    SQL

    db.exec stmt, @viuser_id, @content, @details, @link_to, @_undo_tag_, @created_at
  end

  def self.count_by_user(viuser_id : Int32)
    @@db.query_one(<<-SQL, viuser_id, as: Int32)
      select COALESCE(COUNT(*), 0)::int from #{@@table}
      where viuser_id = $1
    SQL
  end

  def self.mark_as_read(ids : Enumerable(Int32), reached_at = Time.utc)
    @@db.query <<-SQL, ids
      update #{@@table} set reached_at = $1
      where id = any ($2) and reached_at is null
    SQL
  end

  def self.count_unread(viuser_id : Int32)
    @@db.query_one(<<-SQL, viuser_id, as: Int32)
      select COALESCE(COUNT(*), 0)::int from #{@@table}
      where viuser_id = $1
      and reached_at is null
    SQL
  end

  def self.user_notifs(viuser_id : Int32, limit = 20, offset = 0) : Array(self)
    @@db.query_all <<-SQL, viuser_id, limit, offset, as: self
      select * from #{@@table}
      where viuser_id = $1
      limit $2 offset $3
      order by created_at desc
    SQL
  end

  def self.find_by_utag(undo_tag : String)
    @@db.query_one? <<-SQL, undo_tag, as: self
      select * from #{@@table} where _undo_tag_ = $1
    SQL
  end

  def self.new_repl_like(
    viuser_id : Int32,
    from_user : String,
    murepl_id : Int32,
    repl_peak : String,
    thread_type : String,
    thread_name : String,
    thread_link : String
  )
    _undo_tag_ = gen_undo_tag(:repl, viuser_id, murepl_id)
    find_by_utag(_undo_tag_).try { |existed| return existed }

    new(
      viuser_id: viuser_id,
      content: content,
      link_to: link_to,
      details: details.to_json,
      _undo_tag_: _undo_tag_
    )
  end

  def self.new_repl_like(
    viuser_id : Int32,
    from_user : String,
    dtopic_id : Int32,
    thread_name : String,
    thread_link : String
  )
    _undo_tag_ = gen_undo_tag(:repl, viuser_id, murepl_id)
    find_by_utag(_undo_tag_).try { |existed| return existed }

    details = {_type: "like-repl", from_user: from_user, murepl_id: murepl_id}
    link_to = "#{thread_link}#r#{murepl_id}"
    content = <<-HTML
      <p><a href="/@#{from_user}>" class="cv-user">#{from_user}</a> đã thích bài viết của bạn trong #{thread_type} <a href="#{link_to}">#{thread_name}</a>.</p>
      <p>#{repl_peak}<em>
      HTML

    new(
      viuser_id: viuser_id,
      content: content,
      link_to: link_to,
      details: details.to_json,
      _undo_tag_: _undo_tag_
    )
  end

  def self.gen_undo_tag(type : String | Symbol, user : Int32, ukey : String | Int32)
    "#{type}:#{user}:#{ukey}"
  end
end
