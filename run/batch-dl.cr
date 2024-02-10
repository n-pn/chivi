require "http/client"
require "log"
require "colorize"

def download(link, label = "")
  uri = URI.parse(link)
  path = uri.path.split('/')
  hash, name = path[-2], path[-1]

  fname = "#{hash[0..6]}-#{URI.decode(name)}"
  out_path = "#{OUT_DIR}/#{fname}"

  return {out_path, -1} if File.file?(out_path)

  HTTP::Client.get(link) do |res|
    if !res.success?
      Log.warn { "<#{label}> #{fname} invalid, skipping!".colorize.red }
      File.open("#{uri.hostname}-to_redo.txt", "a", &.puts(link))
      return {out_path, -1}
    end

    res_size = res.headers["Content-Length"].to_i
    Log.info { "<#{label}> #{fname} #{res_size.humanize}" }

    tmp_path = "#{out_path}-tmp"
    File.open(tmp_path, "wb") { |file_io| IO.copy(res.body_io, file_io) }

    sleep 50.milliseconds # ensure file is flushed fully
    tmp_size = File.size(tmp_path)

    if tmp_size == res_size && tmp_size > 368
      File.rename(tmp_path, out_path)
      return {out_path, res_size}
    end

    Log.error { "#{out_path} size mismatch (src: #{res_size}, dst: #{tmp_size})".colorize.red }
    Log.info { link.colorize.yellow }
    File.open("to_redo.txt", "a", &.puts(link))

    err_file = "#{out_path}.err"
    File.delete?(err_file)
    File.rename(tmp_path, err_file)

    {out_path, res_size}
  end
end

def download_all(host, links : Array(String), threads = 5)
  threads = {links.size, threads}.min

  pending = Channel({String, String}).new(links.size)
  results = Channel({String, Int32}).new(threads)

  spawn do
    links.each_with_index(1) { |link, idx| pending.send({link, "#{idx}/#{links.size}"}) }
  end

  threads.times do
    spawn do
      loop { results.send(download(*pending.receive)) }
    end
  end

  links.size.times do
    out_path, res_size = results.receive
    File.open("pending-#{host}.txt", "a", &.puts("#{out_path}\t#{res_size}")) if res_size > 0
  end
end

links = File.read_lines(ARGV[0]).reject!(&.blank?).uniq!
OUT_DIR = ARGV[1]? || "download"

queues = links.group_by { |link| URI.parse(link).hostname }

out_ch = Channel(Nil).new(queues.size)

queues.each do |host, links|
  spawn do
    puts host
    download_all(host, links)
    out_ch.send(nil)
  end
end

queues.size.times { out_ch.receive }
