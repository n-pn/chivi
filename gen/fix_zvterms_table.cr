require "../src/mt_ai/data/pg_defn"

inputs = MT::PgDefn.get_all(db: ZR_DB)

inputs.sort_by!(&.mtime)

inputs.select! do |input|
  next false if input.zstr.matches?(/^\p{Han}+$/)
  input.zstr = CharUtil.canonize(input.zstr)
  true
end

puts inputs.size

inputs.each_slice(10000) do |slice|
  puts slice.size

  ZR_DB.transaction do |tx|
    slice.each(&.upsert!(db: tx.connection))
  end
end
