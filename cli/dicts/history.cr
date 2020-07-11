def type_of_action(action)
  case action
  when "Added"
    :add
  when "Deleted"
    :del
  else
    :upd
  end
end

def parse_time(date)
  Time.parse!(date, "%F %T.%3N%:z")
end

alias History = Tuple(String, Symbol, Time)

def load_history(file, hash = Hash(String, History).new)
  File.each_line(file) do |line|
    key, action, user, date = line.strip.split("\t")
    next if key == "Entry"

    action = type_of_action(action)
    mftime = parse_time(date)

    hash[key] = {user, action, mftime}
  end

  hash
end
