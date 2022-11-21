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
      Log.info { "[#{term.key}  #{term.val}]".colorize(color) }
      next unless persist
      db.exec update_query, args: [new_ptag, term.id]
    end
  end
end

def remap(map : Hash(String, String), persist = false)
  map.each do |ptag, new_ptag|
    fix_tags("core", ptag, new_ptag, persist: persist)
    fix_tags("book", ptag, new_ptag, persist: persist)
  end
end

puncts = {
  "Xp_o"   => "Pu_o",
  "Xp_pm"  => "Pu_fs",
  "Xp_em"  => "Pu_em",
  "Xp_qm"  => "Pu_qm",
  "Xp_dq"  => "Pu_dq",
  "Xp_sq"  => "Pu_sq",
  "Xp_ts1" => "Pu_ts1",
  "Xp_ts2" => "Pu_ts2",
  "Xp_ts3" => "Pu_ts3",
  "Xp_qs1" => "Pu_qs1",
  "Xp_qs2" => "Pu_qs2",
  "Xp_bs1" => "Pu_bs1",
  "Xp_bs2" => "Pu_bs2",
  "Xp_ps1" => "Pu_ps1",
  "Xp_tc1" => "Pu_tc1",
  "Xp_tc2" => "Pu_tc2",
  "Xp_tc3" => "Pu_tc3",
  "Xp_qc1" => "Pu_qc1",
  "Xp_qc2" => "Pu_qc2",
  "Xp_bc1" => "Pu_bc1",
  "Xp_bc2" => "Pu_bc2",
  "Xp_pc1" => "Pu_pc1",
  "Xp_cl"  => "Pu_cl",
  "Xp_sc"  => "Pu_sc",
  "Xp_cm"  => "Pu_cm",
  "Xp_ce"  => "Pu_ce",
  "Xp_d1"  => "Pu_d1",
  "Xp_d2"  => "Pu_d2",
  "Xp_e1"  => "Pu_e1",
  "Xp_e2"  => "Pu_e2",
  "Xp_td"  => "Pu_td",
  "Xp_md"  => "Pu_md",
  "Xp_as"  => "Pu_as",
  "Xp_pc"  => "Pu_pc",
  "Xp_qt"  => "Pu_qt",
  "Xp_pl"  => "Pu_pl",
  "Xp_mn"  => "Pu_mn",
  "Xp_ws"  => "Pu_ws",
}

adjts = {
  "An"   => "Ajno",
  "Ad"   => "Ajad",
  "Aa"   => "Adjt",
  "Ab"   => "Amod_1",
  "Al_"  => "Amix",
  "Al_z" => "Ades",

}

names = {
  "Eh_x" => "Name_h",
  "Es_i" => "Name_si",
  "Es_p" => "Name_sp",
  "Ez_b" => "Name_b",
  "Ez_x" => "Name_z",
  "Ez_w" => "Name_zw",
}

advbs = {
  "Fd_corr" => "Adv_correl",
  "Fd_degr" => "Adv_degree",
  "Fd_freq" => "Adv_freq",
  "Fd_mood" => "Adv_mood",
  "Fd_nega" => "Adv_nega",
  "Fd_time" => "Adv_time",
  "Fd_scop" => "Adv_scope",
  "Fd_mann" => "Adv_manner",

  "Fd_bie"  => "Adv_bie",
  "Fd_bu4"  => "Adv_bu4",
  "Fd_cai"  => "Adv_cai",
  "Fd_du1"  => "Adv_du1",
  "Fd_fei"  => "Adv_fei",
  "Fd_hen"  => "Adv_hen",
  "Fd_hoan" => "Adv_hoan",
  "Fd_jiu3" => "Adv_jiu3",
  "Fd_mei"  => "Adv_mei",
  "Fd_ye3"  => "Adv_ye3",
  "Fd_you"  => "Adv_you",
  "Fd_zai"  => "Adv_zai",
  "Fd_zong" => "Adv_zong",
  "Fd_zui"  => "Adv_zui",
  "Fd_x"    => "Advb",
}

persist = ARGV.includes?("--save")

# remap(puncts, persist: persist)
# remap(names, persist: persist)
# remap(adjts, persist: persist)
remap(advbs, persist: persist)
