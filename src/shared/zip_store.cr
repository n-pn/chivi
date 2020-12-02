require "compress/zip"

class Chivi::ZipStore
  getter zip_file : String
  getter root_dir : String

  def initialize(@zip_file, @root_dir = zip_file.sub(/.zip$/, ""))
  end

  def entries(min_size : Int32 = 1)
    zip_entries.concat(dir_entries).uniq!
  end

  def zip_entries(min_size : Int32 = 1)
    return [] of String unless zip_exists?

    open_zip do |zip|
      zip.entries
        # skip files if file size smaller than min_size
        .reject { |x| x.uncompressed_size < min_size }
        .map(&.filename)
    end
  end

  def dir_entries(min_size : Int32 = 1)
    return [] of String unless dir_exists?

    Dir.children(@root_dir).reject do |fname|
      fpath = root_path(fname)
      # skip files if file size smaller than min_size
      File.directory?(fpath) || File.size(fpath) < min_size
    end
  end

  def zip_exists?
    File.exists?(@zip_file)
  end

  def dir_exists?
    File.directory?(@root_dir)
  end

  def exists?(fname : String) : Bool
    return true if File.exists?(root_path(fname))

    if zip_exists?
      open_zip { |zip| return true if zip[fname]? }
    end

    false
  end

  def extract!(fname : String)
    fpath = root_path(fname)
    return File.read(fpath) if File.exists?(fpath)

    return unless zip_exists?
    open_zip(&.[fname]?.try(&.open(&.gets_to_end)))
  end

  def mtime(fname : String)
    File.info?(root_path(fname)).try { |x| return x.modification_time }
    zip_entry(fname, &.try(&.time))
  end

  def compress!(mode : Symbol = :update, glob = "*.*") : Nil
    return puts "[Nothing to compress!]" if Dir.empty?(root_dir)

    # set flags
    # `-j` means remove folder root
    # `-q` means quiet output mode

    case mode
    when :archive
      flags = "-jqm" # move file to zip
    when :freshen
      flags = "-jqfm" # only move existed (in zip) files
    else
      flags = "-jqu" # update if newer
    end

    puts `zip #{flags} #{zip_file} #{root_dir}/#{glob}`
  end

  private def root_path(fname : String)
    File.join(@root_dir, fname)
  end

  private def open_zip
    Compress::Zip::File.open(zip_file) { |zip| yield zip }
  end

  private def zip_entry(fname : String)
    return unless zip_exists?
    open_zip { |zip| yield zip[fname]? }
  end
end
