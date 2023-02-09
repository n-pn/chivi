require "../src/mt_v1/mt_core"
require "../src/mt_v1/data/v1_dict"
require "../src/_data/dl_tran"

force = ARGV.includes?("-f")

tasks = CV::DlTran.repo.open_db do |db|
  query = String.build do |sql|
    sql << "select * from dltrans where _flag = 0"
    sql << " or _flag = 1" if force
    sql << " order by privi desc"
  end

  db.query_all(query, as: CV::DlTran)
end

CV::DlTran.repo.open_db do |db|
  db.exec "update dltrans set _flag = 1 where _flag = 0"
end

def do_convert(engine, out_file : File, inp_path : String)
  chap_count = 0
  is_title = true

  File.each_line(inp_path, encoding: "GB18030") do |line|
    chap_count += line.size &+ 1

    data = is_title ? engine.cv_title(line) : engine.cv_plain(line)
    data.to_txt(out_file)

    out_file << '\n'
    is_title = false
  rescue
    out_file.puts "Lỗi dịch thuật!"
  end

  chap_count
end

def run_task(task : CV::DlTran)
  dname = M1::DbDict.get_dname(-task.wn_id)
  engine = CV::MtCore.generic_mtl(dname, user: task.uname)

  Dir.mkdir_p("var/texts/dlcvs/#{task.uname}")

  out_path = "var/texts/dlcvs/#{task.uname}/#{task.id}.txt"
  out_file = File.open(out_path, "w")

  word_count = 0

  txt_dir = "var/texts/rgbks/#{task.sname}/#{task.s_bid}"

  task.from_ch_no.upto(task.upto_ch_no) do |ch_no|
    txt_path = "#{txt_dir}/#{ch_no}.gbk"

    if File.file?(txt_path)
      word_count += do_convert(engine, out_file, txt_path)
    else
      out_file << "Chương thứ #{ch_no} không có text gốc, mời kiểm tra lại!"
    end

    out_file << '\n' << '\n' unless ch_no == task.upto_ch_no
  end

  out_file.close

  CV::DlTran.repo.open_tx do |db|
    query = "update dltrans set _flag = 2, real_word_count = ? where id = ?"
    db.exec query, word_count, task.id
  end
end

tasks.each do |task|
  run_task(task)
rescue err
  File.open("tmp/mass_convert_error.log", "a", &.puts(err.message))

  CV::DlTran.repo.open_db do |db|
    db.exec "update dltrans set _flag = -1 where id = ?", task.id
  end
end
