require "colorize"
require "http/client"

SRC = "https://fetch.nipin.workers.dev?q=https://www.69xinshu.com/book/%s/"
DIR = "var/.keep/rmbook/69xinshu.com"

Dir.mkdir_p(DIR)
FROM =     1
UPTO = 55408

UPTO.to(FROM) do |sn_id|
  file = File.join(DIR, "#{sn_id}-cata.htm")
  next if File.file?(file)

  link = SRC % sn_id
  res = HTTP::Client.get(link)

  if res.status.success?
    File.write(file, res.body)
    Log.info { "#{file} is saved".colorize.green }
  else
    Log.warn { "#{res.status}: #{res.body}".colorize.red }
  end
end
