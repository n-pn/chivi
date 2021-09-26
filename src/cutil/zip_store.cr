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

  def initialize(@zip_file, @root_dir = File.basename(@zip_file, ".zip"))
  end

  def entries(min_size : Int32 = 1)
    zip_entries.concat(dir_entries).uniq!
  end

  def zip_entries(min_size : Int32 = 1)
    open_zip do |zip|
      # skip files if file size smaller than min_size
      zip.entries.reject { |x| x.uncompressed_size < min_size }.map(&.filename)
    end || [] of String
  end

  def zip_entry(fname : String)
    open_zip { |zip| yield zip[fname]? }
  end

  private def open_zip
    return unless File.exists?(@zip_file)
    Compress::Zip::File.open(@zip_file) { |zip| yield zip }
  end

  def archived?(fname : String) : Bool
    zip_entry(fname, &.nil?.!)
  end

  def read(fname : String)
    zip_entry(&.open(&.gets_to_end))
  end

  def mtime(fname : String)
    zip_entry(fname, &.try(&.time))
  end

  def add_file!(fname : String, mode : Symbol = :update) : Nil
    fpath = root_path(fname)
    unless File.exists?(fpath)
      return puts "[File <#{fname}> not found, skip zipping!]".colorize.dark_gray
    end

    flags = zip_flags(mode)
    puts `zip #{flags} #{@zip_file} #{fpath}`
    puts "- [Added file <#{fname}> to zip: <#{@zip_file}>]\n".colorize.yellow
  end

  def compress!(mode : Symbol = :update, glob = "*.*") : Nil
    return puts "[Nothing to compress!]".colorize.dark_gray if Dir.empty?(root_dir)

    flags = zip_flags(mode)
    files = Dir.glob("#{root_dir}/#{glob}")

    puts `zip #{flags} #{@zip_file} #{root_dir}/#{glob}`
    puts "- [Added #{files.size} files to zip: <#{@zip_file}>]\n".colorize.yellow
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
end
