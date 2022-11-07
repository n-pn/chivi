require "compress/zip"
require "colorize"

def load_checked(check_file : String)
  output = Set(String).new
  return output unless File.exists?(check_file)
  output.concat(File.read_lines(check_file))
end

def check_error(dir_path : String)
  files = Dir.glob(File.join(dir_path, "*.zip"))

  check_file = File.join(dir_path, "valid-zip.log")
  checked = load_checked(check_file)

  files.each do |file|
    base_name = File.basename(file, ".zip")
    next if checked.includes?(base_name)

    is_valid = is_valid_zip_file(file)

    if is_valid
      checked << base_name
      next
    end

    puts "#{file} is corrupted".colorize.yellow
    File.rename(file, file.sub(".zip", ".err"))
  end

  File.write(check_file, checked.join('\n'))
end

def redownload(dir_path : String)
  files = Dir.glob(File.join(dir_path, "*.err"))
  return if files.empty?

  files.each do |file|
    puts file
    out_file = file.sub(".err", ".zip")
    File.delete(file) if redownload_file(out_file)
  end
end

def redownload_file(zip_file : String)
  zip_href = zip_file.sub("var/chaps/texts", "https://cr2.chivi.app/texts")
  `curl -L -k -s #{zip_href} -o "#{zip_file}"`
  $?.success?
end

def is_valid_zip_file(zip_file)
  Compress::Zip::File.open(zip_file) do |zip|
    return true if zip.entries.size > 0
    !zip.entries.any?(&.uncompressed_size.== 0)
  end
rescue err
  puts "#{zip_file}: #{err}".colorize.red
  false
end

INP_DIR = "var/chaps/texts"
Dir.glob("#{INP_DIR}/hetushu/*/").each do |dir_path|
  check_error(dir_path)
  # redownload(dir_path)
end
