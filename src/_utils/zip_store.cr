require "compress/zip"

class ZipStore
  getter target : String
  getter source : String

  def initialize(@target, @source = target.sub(/.zip$/, ""))
  end

  def entries(min_size = 20)
    entries = [] of String

    if File.exists?(@target)
      open_zip do |zip|
        files = zip.entries
        files = files.reject { |x| x.uncompressed_size < min_size }

        entries.concat(files.map(&.filename))
      end
    end

    if File.directory?(@source)
      files = Dir.children(@source).reject do |name|
        path = File.join(@source, name)
        File.directory?(path) || File.size(path) < min_size
      end

      entries.concat(files)
    end

    entries.uniq
  end

  def exists?(file : String) : Bool
    return true if File.exists?(file_path(file))
    return false unless File.exists?(@target)

    open_zip { |zip| !!zip[file]? } || false
  end

  def extract(basename : String)
    file = file_path(basename)
    return File.read(file) if File.exists?(file)
    return unless File.exists?(@target)

    open_zip { |zip| zip[basename]?.try(&.open(&.gets_to_end)) }
  end

  def mtime(basename : String)
    file = file_path(basename)
    return File.info(file).modification_time if File.exists?(file)
    return unless File.exists?(@target)

    open_zip { |zip| zip[basename]?.try(&.time) }
  end

  private def file_path(file : String)
    File.join(@source, file)
  end

  def compress!(mode : Symbol = :update) : Nil
    return puts "Nothing to compress!" if Dir.empty?(source)

    case mode
    when :archive
      flags = "m"
    when :freshen
      flags = "fm"
    else
      flags = "u"
    end

    puts `zip -jq#{flags} "#{target}" #{source}/*.*`
  end

  private def open_zip
    Compress::Zip::File.open(target) do |zip|
      yield zip
    end
  end
end
