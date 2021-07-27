require "./shared/seed_util"
require "./shared/raw_yscrit"

class CV::SeedYscrit
  @checker = ValueMap.new("_db/yousuu/yscrit.tsv")

  def seed_file!(file : String)
    mtime = SeedUtil.get_mtime(file)
    return if mtime < @checker.ival_64(file)

    @checker.set!(file, Time.utc.to_unix)
    crits = RawYscrit.parse_raw(File.read(file))
    crits.each(&.seed!)
  rescue err
    puts err
  end

  def persist_progress!
    @checker.save!
  end

  DIR = "_db/yousuu/crits-latest"

  def self.run!
    worker = new

    Dir.children(DIR).each do |dir|
      files = Dir.glob("#{DIR}/#{dir}/*.json")
      files.each_with_index(1) do |file, idx|
        puts "- <#{idx}/#{files.size}> #{file}"
        worker.seed_file!(file)
      end

      worker.persist_progress!
    end
  end
end

CV::SeedYscrit.run!
