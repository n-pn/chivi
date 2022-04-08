require "../shared/raw_ysrepl"

class CV::SeedYsrepl
  def seed_file!(file : String)
    _total, repls = RawYsrepl.parse_raw(File.read(file))
    stime = File.info(file).modification_time.to_unix
    repls.each(&.seed!(stime))
  end

  DIR = "_db/yousuu/repls"

  def self.run!
    worker = new

    Dir.children(DIR).each do |dir|
      files = Dir.glob("#{DIR}/#{dir}/*.json")
      files.each_with_index(1) do |file, idx|
        puts "- <#{idx}/#{files.size}> #{file}"
        worker.seed_file!(file)
      rescue err
        puts err
      end
    end
  end
end

CV::SeedYsrepl.run!
