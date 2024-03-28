require "colorize"
require "http/client"

def fetch_url(url : String, fpath : String, label : String = "1/1") : Nil
  return puts "<#{label}>: #{fpath} saved, skipping!" if File.file?(fpath)
  html = `curl '#{url}' -fsL --compressed -H 'Accept-Encoding: gzip, deflate, br' -H 'Referer: #{url}'`

  if html.blank?
    puts "<#{label}>: #{url} returning blank!".colorize.red
  else
    File.write(fpath, html)
    puts "<#{label}>: #{url} saved to #{fpath}!".colorize.green
  end
end

UPTO = ARGV[0]?.try(&.to_i) || 56671
FROM = ARGV[1]?.try(&.to_i) || 1

queue = (FROM..UPTO).to_a.shuffle!
qsize = queue.size
wsize = 2

workers = Channel({Int32, Int32}).new(qsize)
results = Channel(Nil).new(wsize)

spawn do
  queue.each_with_index(1) { |sn_id, index| workers.send({sn_id, index}) }
end

URL = "https://www.69shu.pro"
DIR = "/srv/chivi/.keep/rmbook/69shu.pro"
Dir.mkdir_p(DIR)

wsize.times do
  spawn do
    loop do
      sn_id, index = workers.receive
      fetch_url("#{URL}/book/#{sn_id}.htm", "#{DIR}/#{sn_id}.htm", "#{index * 2 - 1}/#{qsize * 2}")
      sleep 100.milliseconds
      fetch_url("#{URL}/book/#{sn_id}/", "#{DIR}/#{sn_id}-cata.htm", "#{index * 2}/#{qsize * 2}")
    rescue err
      Log.error(exception: err) { err.message.colorize.red }
    ensure
      results.send(nil)
    end
  end
end

qsize.times { results.receive }
