require "../src/cvmtl/cv_data/*"

REMAP = {
  "Nr" => "Eh_x",
  "Ns" => "Es_p",
  "Nt" => "Es_i",
  "Nw" => "Ez_w",
  "Nb" => "Ez_b",
  "Nz" => "Ez_x",

  "nh" => "Nh",
  "na" => "Na",
  "nb" => "Nb_",
  "no" => "No_",
  "nc" => "No_",
  "s"  => "Ns_",
  "f"  => "Ns_",
  "t"  => "Nt_",
  "n"  => "Nx",
  "nl" => "Nx_l",

  "a"   => "Aa",
  "~an" => "An",
  "~ad" => "Ad",
  "ab"  => "Ab",
  "a!"  => "Ab",
  "al"  => "Al_",
  "az"  => "Al_z",

  "vi" => "Vi_x",
  "vo" => "Vi_o",
  "vl" => "Vi_l",

  "v"   => "Vt_",
  "~vn" => "Vn",
  "~vd" => "Vd",
  "vd"  => "Vt_d",
  "v!"  => "Vs_",

  "r" => "Rx",

  "m"   => "Mn_",
  "q"   => "Mq_",
  "mq"  => "Mf_",
  "~qt" => "Mq_",
  "~mq" => "Mf_",

  "d"  => "Fd_",
  "c"  => "Fc_",
  "cc" => "Fcc",
  "p"  => "Fp_",
  "u"  => "Fu_",
  "k"  => "Fg_",
  "h"  => "Fg_",

  "y" => "Fo_",

  "x" => "Xs_",
  "w" => "Xw_",

  ""   => "Xl_b",
  "l"  => "Xl_x",
  "li" => "Xl_i",
  "lq" => "Xl_q",
  "lt" => "Xl_t",

  "+pp"  => "!",
  "+sa"  => "!",
  "+sv"  => "!",
  "+dp"  => "!",
  "+dr"  => "!",
  "+dv"  => "!",
  "~vc"  => "Fv",
  "!"    => "!",
  "uden" => "Fu_",
  "~nd"  => "Nb",
}

def fix_dict(type : String)
  MT::CvTerm.open_db_tx(type) do |db|
    ptags = db.query_all "select distinct(ptag) from terms", as: String

    ptags.each do |old_ptag|
      new_ptag = REMAP[old_ptag]
      puts "#{old_ptag} => #{new_ptag}"
      db.exec "update terms set ptag = ? where ptag = ?", args: [new_ptag, old_ptag]
    end
  end
end

# puts ptags
# fix_dict("core")
# fix_dict("book")
