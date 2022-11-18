require "../src/cvmtl/cv_data/*"

record Term, id : Int32, key : String, val : String do
  include DB::Serializable
end

def fix_tags(type : String, ptag : String, new_ptag : String, persist = false)
  color = persist ? :yellow : :blue
  puts "#{ptag} => #{new_ptag}"

  MT::CvTerm.open_db_tx(type) do |db|
    query = "select id, key, val from terms where ptag = ?"
    terms = db.query_all query, args: [ptag], as: Term

    update_query = "update terms set ptag = ? where id = ?"

    terms.each do |term|
      puts "[#{term.key}  #{term.val}]".colorize(color)
      next unless persist
      db.exec update_query, args: [new_ptag, term.id]
    end
  end
end

persist = ARGV.includes?("--save")

REMAP_2 = {
  "Xw_z"   => "Xp_o",
  "Xw_pm"  => "Xp_pm",
  "Xw_em"  => "Xp_em",
  "Xw_qm"  => "Xp_qm",
  "Xw_dq"  => "Xp_dq",
  "Xw_sq"  => "Xp_sq",
  "Xw_ts1" => "Xp_ts1",
  "Xw_ts2" => "Xp_ts2",
  "Xw_ts3" => "Xp_ts3",
  "Xw_qs1" => "Xp_qs1",
  "Xw_qs2" => "Xp_qs2",
  "Xw_bs1" => "Xp_bs1",
  "Xw_bs2" => "Xp_bs2",
  "Xw_ps1" => "Xp_ps1",
  "Xw_tc1" => "Xp_tc1",
  "Xw_tc2" => "Xp_tc2",
  "Xw_tc3" => "Xp_tc3",
  "Xw_qc1" => "Xp_qc1",
  "Xw_qc2" => "Xp_qc2",
  "Xw_bc1" => "Xp_bc1",
  "Xw_bc2" => "Xp_bc2",
  "Xw_pc1" => "Xp_pc1",
  "Xw_cl"  => "Xp_cl",
  "Xw_sc"  => "Xp_sc",
  "Xw_cm"  => "Xp_cm",
  "Xw_ce"  => "Xp_ce",
  "Xw_d1"  => "Xp_d1",
  "Xw_d2"  => "Xp_d2",
  "Xw_e1"  => "Xp_e1",
  "Xw_e2"  => "Xp_e2",
  "Xw_td"  => "Xp_td",
  "Xw_md"  => "Xp_md",
  "Xw_as"  => "Xp_as",
  "Xw_pc"  => "Xp_pc",
  "Xw_qt"  => "Xp_qt",
  "Xw_pl"  => "Xp_pl",
  "Xw_mn"  => "Xp_mn",
  "Xw_ws"  => "Xp_ws",
}

REMAP_2.each do |ptag, new_ptag|
  fix_tags("core", ptag, new_ptag, persist: persist)
  fix_tags("book", ptag, new_ptag, persist: persist)
end
