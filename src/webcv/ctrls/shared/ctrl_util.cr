module CV::CtrlUtil
  extend self

  def pgmax(total : Int, limit : Int)
    (total &- 1) // limit &+ 1
  end

  LOG_DIR = "var/pg_data/weblogs"

  def log_user_action(type : String, data : Object, user = "")
    time_now = Time.local.to_s
    log_file = "#{LOG_DIR}/#{type}-#{time_now.split(' ', 2).first}.log"
    File.open(log_file, "a", &.puts("#{time_now}\t#{user}\t #{data.to_json}"))
  end
end
