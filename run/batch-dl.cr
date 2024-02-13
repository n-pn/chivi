require "http/client"
require "log"
require "colorize"

def download(link, fpath, label = "")
  host = URI.parse(link).hostname

  out_path = "#{OUT_DIR}/#{fpath}"
  return {out_path, -1_i64} if File.file?(out_path)

  HTTP::Client.get(link) do |res|
    res_size = res.headers["Content-Length"].to_i64
    Log.info { "<#{label}> #{fpath} #{res_size.humanize}" }

    if !res.success? || res_size > 30_000_000
      Log.warn { "<#{label}> #{fpath} is either invalid or too large, skipping!".colorize.red }
      File.open("#{host}-redo.tsv", "a", &.puts("#{fpath}\t#{link}"))
      return {out_path, -1_i64}
    end

    tmp_path = "#{out_path}-tmp"
    File.open(tmp_path, "wb") { |file_io| IO.copy(res.body_io, file_io) }

    sleep 50.milliseconds # ensure file is flushed fully
    tmp_size = File.size(tmp_path)

    if tmp_size == res_size
      File.rename(tmp_path, out_path)
      return {out_path, res_size}
    end

    Log.error { "#{out_path} size mismatch (src: #{res_size}, dst: #{tmp_size})".colorize.red }
    Log.info { link.colorize.yellow }
    File.open("too_large-#{host}.txt", "a", &.puts("#{fpath}\t#{link}"))

    err_file = "#{out_path}.err"
    File.delete?(err_file)
    File.rename(tmp_path, err_file)

    {out_path, res_size}
  rescue
    {out_path, -1_i64}
  end
end

def download_all(host, links : Array(String), threads = 5)
  threads = {links.size, threads}.min

  pending = Channel({String, String, String}).new(links.size)
  results = Channel({String, Int64}).new(threads)

  spawn do
    links.each_with_index(1) do |line, idx|
      link, name = line.split('\t')
      pending.send({link, name, "#{idx}/#{links.size}"})
    end
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

OUT_DIR = ARGV[1]? || "download"

host = File.basename(ARGV[0], ".tsv")
list = File.read_lines(ARGV[0]).reject!(&.blank?).uniq!.shuffle!

download_all(host, list)
