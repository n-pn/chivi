require "./shared/*"

class Hanviet
  HANZIDB = QtDict.load("_system/hanzidb.txt")

  TRADSIM = CV::VpDict.tradsim
  BINH_AM = CV::VpDict.binh_am

  getter input : QtDict = QtDict.load("_autogen/hanviet.txt", false)

  def merge!(file : String, mode = :old_first)
    QtDict.load(file).each do |key, vals|
      QtUtil.lexicon.add(key)

      next if key =~ /\P{Han}/
      @input.upsert(key, vals, mode)
    end
  end

  def gen_from_trad!
    TRADSIM._root.each do |node|
      next unless entry = node.entry

      next if entry.key.size > 0
      next unless vals = @input[entry.key]?

      entry.vals.each do |simp|
        next if @input.has_key?(simp)
        @input.upsert(simp, vals)
      end
    end
  end

  def save!
    hanviet_file = "_db/dictdb/active/system/hanviet.tsv"
    File.delete(hanviet_file) if File.exists?(hanviet_file)

    output = CV::VpDict.load("hanviet", regen: true)

    input = @input.to_a.sort_by(&.[0].size)
    input.each do |(key, vals)|
      next if key.size > 4
      next unless first = vals.first?

      if key.size > 1
        convert = QtUtil.convert(output, key, " ")
        next if first == convert
        pp [key, vals, convert]
      end

      output.add(CV::VpEntry.new(key, vals.uniq.first(3)))
    end

    output.load!("_db/dictdb/remote/system/hanviet.tsv")
    output.save!
  end
end

task = Hanviet.new

task.merge!("localqt/hanviet.txt")
task.merge!("hanviet/lacviet-chars.txt")
task.merge!("hanviet/lacviet-words.txt")

task.merge!("hanviet/trichdan-chars.txt")
task.merge!("hanviet/trichdan-words.txt")

task.merge!("hanviet/verified-chars.txt", mode: :keep_new)
task.merge!("hanviet/verified-words.txt", mode: :keep_new)

task.merge!("hanviet/correct-chars.txt", mode: :keep_new)

task.gen_from_trad!
task.save!

QtUtil.lexicon.save!
