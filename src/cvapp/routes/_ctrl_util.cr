require "../../_util/hash_util"

module CV::CtrlUtil
  extend self

  def pgmax(total : Int, limit : Int)
    (total &- 1) // limit &+ 1
  end

  def pg_no(index : Int, limit : Int)
    (index &- 1) // limit &+ 1
  end

  def offset(pgidx : Int32, limit : Int32)
    (pgidx &- 1) &* limit
  end

  LOG_DIR = "var/.keep/web_log"
  Dir.mkdir_p(LOG_DIR)

  def log_user_action(type : String, data : Object, uname = "")
    time_now = Time.local.to_s
    log_file = "#{LOG_DIR}/#{type}-#{time_now.split(' ', 2).first}.log"
    File.open(log_file, "a") { |io| io << Time.local << '\t' << uname << '\t' << data.to_json << '\n' }
  end
end
