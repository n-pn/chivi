require "compress/zip"

class CV::ZipStore
  def self.read(file : String)
    dir_path = File.dirname(file)
    zip_file = "#{dir_path}.zip"

    new(zip_file, dir_path).read(File.basename(file))
  end

  def self.read(zip_file : String, entry_name : String)
    new(zip_file).read(entry_name)
  end

  getter zip_file : String
  getter root_dir : String

  def initialize(@zip_file, @root_dir = zip_file.sub(/.zip$/, ""))
  end

  def entries(min_size : Int32 = 1)
    zip_entries.concat(dir_entries).uniq!
  end

  def zip_entries(min_size : Int32 = 1)
    return [] of String unless File.exists?(@zip_file)

    open_zip do |zip|
      zip.entries
        # skip files if file size smaller than min_size
        .reject { |x| x.uncompressed_size < min_size }
        .map(&.filename)
    end
  end

  def dir_entries(min_size : Int32 = 1)
    return [] of String unless File.directory?(@root_dir)

    Dir.children(@root_dir).reject do |fname|
      fpath = root_path(fname)
      # skip files if file size smaller than min_size
      File.directory?(fpath) || File.size(fpath) < min_size
    end
  end

  def exists?(fname : String) : Bool
    return true if File.exists?(root_path(fname))
    open_zip { |zip| return true if zip[fname]? } || false
  end

  def read(fname : String)
    fpath = root_path(fname)
    return File.read(fpath) if File.exists?(fpath)
    open_zip(&.[fname]?.try(&.open(&.gets_to_end)))
  end

  def mtime(fname : String)
    File.info?(root_path(fname)).try { |x| return x.modification_time }
    zip_entry(fname, &.try(&.time))
  end

  def add_file!(fname : String, mode : Symbol = :update) : Nil
    fpath = root_path(fname)
    unless File.exists?(fpath)
      return puts "[File <#{fname}> not found, skip zipping!]".colorize.dark_gray
    end

    flags = zip_flags(mode)
    puts "[Add file <#{fname}> to zip: <#{@zip_file}>]"
    puts `zip #{flags} #{@zip_file} #{fpath}`
  end

  def compress!(mode : Symbol = :update, glob = "*.*") : Nil
    if Dir.empty?(root_dir)
      return puts "[Nothing to compress!]".colorize.dark_gray
    end

    flags = zip_flags(mode)

    puts "[Add files to zip: <#{@zip_file}>]"
    puts `zip #{flags} #{@zip_file} #{root_dir}/#{glob}`
  end

  def zip_flags(mode : Symbol)
    # zip flags:
    # `-j` means remove folder root
    # `-q` means quiet output mode

    case mode
    when :archive
      "-jqm" # move file to zip
    when :freshen
      "-jqfm" # only move existed (in zip) files
    else
      "-jqu" # update if newer
    end
  end

  def root_path(fname : String)
    File.join(@root_dir, fname)
  end

  private def open_zip
    return unless File.exists?(@zip_file)
    Compress::Zip::File.open(@zip_file) { |zip| yield zip }
  end

  private def zip_entry(fname : String)
    open_zip { |zip| yield zip[fname]? }
  end
end
