require "mime"
require "digest"
require "colorize"
require "http/client"

module Utils
  TLS = OpenSSL::SSL::Context::Client.insecure

  def self.download_file(url, name : String? = nil, ext : String? = nil, dir = "data/txt-tmp/covers")
    name ||= Digest::SHA1.hexdigest(url)[0..10]

    files = Dir.glob("#{dir}/#{name}.*") # .reject { |f| File.size(f) == 0 }
    return files.first unless files.empty?

    uri = URI.parse(url)
    tls = url.starts_with?("https") ? TLS : false # TODO: check by uri?

    return "" unless uri.host && uri.full_path

    client = HTTP::Client.new(uri.host.not_nil!, tls: tls)
    client.dns_timeout = 5
    client.read_timeout = 5
    client.connect_timeout = 5

    begin
      res = client.get(uri.full_path.not_nil!)

      ext ||= MIME.extensions(res.mime_type.to_s).first
      file = "#{name}#{ext}"

      File.write(File.join(dir, file), res.body_io)
      file
    rescue err
      puts "Error downloading <#{url}>: #{err.colorize(:red)}"
      FileUtils.touch("#{name}.jpg")
      ""
    end
  end
end
