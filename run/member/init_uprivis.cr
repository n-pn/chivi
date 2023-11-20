ENV["CV_ENV"] ||= "production"
require "../../src/_data/member/uprivi"

SQL = <<-SQL
  select id, privi, privi_until, vcoin from viusers order by id asc;
SQL

viusers = PGDB.query_all SQL, as: {Int32, Int32, Array(Int64), Float64}

uprivis = viusers.map do |vu_id, privi, until_arr, vcoin|
  p_exp = privi.in?(1..3) ? until_arr[privi - 1] : 0_i64

  uprivi = CV::Uprivi.new(vu_id, p_now: privi.to_i16, p_exp: p_exp)

  unless until_arr.empty?
    exp_0 = {until_arr.max + 86400 * 60, Time.utc.to_unix - 86400 * 5}.max
    exp_0 += 86400 * vcoin.round.to_i

    uprivi.exp_a = [
      exp_0,
      until_arr[0]? || 0_i64,
      until_arr[1]? || 0_i64,
      until_arr[2]? || 0_i64,
    ]
  end

  uprivi.fix_privi!

  if uprivi.p_now.in?(0..3)
    uprivi.exp_a[0] = {uprivi.exp_a[0], Time.utc.to_unix + 86400 * 60}.max
  end

  uprivi
end

puts uprivis.size
puts uprivis.count(&.p_now.== 0)
puts uprivis.count(&.p_now.== 1)
puts uprivis.count(&.p_now.== 2)
puts uprivis.count(&.p_now.== 3)
puts uprivis.count(&.p_now.> 3)

PGDB.exec "begin"
uprivis.each(&.upsert!(db: PGDB))
query = "update viusers set privi = $1, p_exp = $2 where id = $3"

uprivis.each do |uprivi|
  PGDB.exec query, uprivi.p_now, uprivi.p_exp, uprivi.vu_id
end

PGDB.exec "commit"
