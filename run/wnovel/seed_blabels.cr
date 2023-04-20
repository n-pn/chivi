require "colorize"
require "../../src/_data/wnovel/blabel"

def gen_seed_labels
  seeds = PGDB.query_all <<-SQL, as: String
  select distinct(sname) from wnseeds
  where chap_total > 0
  SQL

  seeds.reject!(&.== "_")

  blabels = seeds.map do |seed|
    blabel = CV::Blabel.new(
      name: seed,
      type: CV::Blabel::Type::Seed.value,
      slug: seed,
    )

    blabel.book_count = PGDB.query_one <<-SQL, seed, as: Int32
    select count(*)::int from wnseeds where sname = $1
    SQL

    puts blabel.to_pretty_json.colorize.blue
    blabel
  end

  blabels.sort_by!(&.book_count.-).each(&.upsert!)

  # TODO: generate users meta seed
end

def gen_orig_labels
  origs = PGDB.query_all <<-SQL, as: String
  select distinct("name") from wnlinks;
  SQL

  blabels = origs.map do |orig|
    blabel = CV::Blabel.new(
      name: orig,
      type: CV::Blabel::Type::Orig.value,
      slug: orig,
    )

    blabel.book_count = PGDB.query_one <<-SQL, orig, as: Int32
    select count(*)::int from wnlinks where name = $1
    SQL

    puts blabel.to_pretty_json.colorize.blue
    blabel
  end

  blabels.sort_by!(&.book_count.-).each(&.upsert!)
end

gen_seed_labels
gen_orig_labels
