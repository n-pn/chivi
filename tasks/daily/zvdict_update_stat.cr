ENV["CV_ENV"] ||= "production"
require "../../src/mt_ai/data/pg_dict"

update_query = <<-SQL
  update zvdict set total = $1, mtime = $2, users = $3
  where d_id = $4
SQL

record ZvTerm, d_id : Int32, mtime : Int32, uname : String do
  include DB::Serializable
end

dicts = MT::PgDict.db.query_all "select * from zvdict", as: MT::PgDict
terms = MT::PgDict.db.query_all "select d_id, mtime, uname from zvterm", as: ZvTerm

terms = terms.group_by(&.d_id)

dicts.each_slice(500) do |group|
  group.select! do |zdict|
    next false unless avail = terms[zdict.d_id]?

    zdict.total = avail.size

    zdict.mtime = avail.max_of(&.mtime)
    zdict.users = avail.map(&.uname).uniq!.reject!(&.empty?)

    true
  end

  next if group.empty?
  puts "saving: #{group.size}"

  MT::PgDict.db.transaction do |tx|
    group.each(&.upsert!(db: tx.connection))
  end
end
