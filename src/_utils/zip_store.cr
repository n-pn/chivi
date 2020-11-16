require "compress/zip"

class ZipStore
  getter target : String
  getter source : String

  def initialize(@target, @source = target.sub(/.zip$/, ""))
  end

  def exists?(file : String)
    return true if File.exists?(file_path(file))
    return false unless File.exists?(@target)

    Compress::Zip::File.open(target) { |zip| return true if zip[file]? }
    false
  end

  def extract(basename : String)
    file = file_path(basename)
    return File.read(file) if File.exists?(file)
    return unless File.exists?(@target)

    Compress::Zip::File.open(target) do |zip|
      zip[basename]?.try(&.open(&.gets_to_end))
    end
  end

  def mtime(basename : String)
    file = file_path(basename)
    return File.info(file).modification_time if File.exists?(file)
    return unless File.exists?(@target)

    Compress::Zip::File.open(target) do |zip|
      zip[basename]?.try(&.time)
    end
  end

  private def file_path(file : String)
    File.join(@source, file)
  end

  def compress!(move : Bool = true) : Nil
    return puts "Nothing to compress!" if Dir.empty?(source)

    options = "-j"
    options += "m" if move

    puts `zip #{options} "#{target}" #{source}/*.*`
  end
end
