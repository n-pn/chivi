require "mime"
require "digest"
require "colorize"
require "http/client"
require "file_utils"

require "../../src/_oldcv/kernel/models/book_info"

class Oldcv::FetchCovers
  TMP_DIR = "_db/.cover/.miscs"
  OUT_DIR = "web/public/covers"

  # FILE_DF = File.join(TMP_DIR, "blank.jpg")

  def initialize(@skip_empty = true)
  end

  TLS = OpenSSL::SSL::Context::Client.insecure

  def download_cover(url : String, file : String, label = "1/1") : Void
    return if !@skip_empty && File.exists?(file)

    puts "- <#{label}> [#{url.colorize(:blue)}]"

    uri = URI.parse(url)
    return unless uri.host && uri.full_path

    tls = url.starts_with?("https") ? TLS : false # TODO: check by uri?
    http = HTTP::Client.new(uri.host.not_nil!, tls: tls)

    http.dns_timeout = 10
    http.connect_timeout = 10
    http.read_timeout = 30

    http.get(uri.full_path.not_nil!) do |res|
      # if ext = MIME.extensions(res.mime_type.to_s).first?
      #   if ext != ".jpg" || ext != ".jpeg"
      #     puts "#{url.colorize(:yellow)} : #{ext.colorize(:yellow)}"
      #   end
      # end
      File.write(file, res.body_io.try(&.gets_to_end))
    end
  rescue err
    FileUtils.touch(file)
    puts "- <#{label}> [#{url}] #{err}".colorize.red
  end

  def glob_dir(dir : String)
    glob = {} of String => String

    Dir.children(dir).each do |file|
      name = file.split(".", 2).first
      file = File.join(dir, file)

      next if @skip_empty && File.size(file) == 0
      glob[name] = file
    end

    glob
  end

  getter infos : Array(BookInfo) { BookInfo.load_all! }

  def fetch!
    queue = [] of Tuple(String, String)

    infos.each do |info|
      cover_dir = File.join(TMP_DIR, info.ubid)
      FileUtils.mkdir_p(cover_dir)
      indexed = glob_dir(cover_dir)

      info.cover_urls.each do |site, cover|
        case site
        when "jx_la", "duokan8", "shubaow"
          next
        else
          next if cover.empty?
        end

        # puts info.to_json unless cover.starts_with?("http")

        name = Digest::SHA1.hexdigest(cover)[0..10]
        next if indexed.has_key?(name)

        queue << {cover, File.join(cover_dir, name + ".jpg")}
      end
    end

    puts "- pending: #{queue.size}"

    unless queue.size < 12
      limit = 12
      limit = queue.size if queue.size < limit

      channel = Channel(Nil).new(limit)

      queue.each_with_index do |(url, file), idx|
        channel.receive unless idx < limit
        spawn do
          download_cover(url, file, "#{idx + 1}/#{queue.size}")
        ensure
          channel.send(nil)
        end
      end

      limit.times { channel.receive }
    end
  end

  def save!
    # TODO: copy best covers to web/upload folder
    infos.each do |info|
      best_file = ""
      best_size = 0

      cover_dir = File.join(TMP_DIR, info.ubid)
      cover_files = glob_dir(cover_dir).values

      cover_files.each do |file|
        size = File.size(file)

        if size > best_size
          best_file = file
          best_size = size
        end
      end

      next if best_file.empty?

      main_cover = File.basename(best_file)
      info.main_cover = main_cover
      next unless info.changed?

      info.save!
      out_file = File.join(OUT_DIR, "#{info.ubid}.#{main_cover}")
      FileUtils.cp(best_file, out_file)
    end
  end
end

worker = Oldcv::FetchCovers.new(ARGV.includes?("skip_empty"))
worker.fetch!
worker.save!
