require "./shared/*"
require "../../src/engine/library"

class Hanviet
  HANZIDB = QtDict.load("_system/hanzidb.txt")

  TRADSIM = Chivi::Library.tradsim
  BINH_AM = Chivi::Library.binh_am

  getter input : QtDict = QtDict.load("_autogen/hanviet.txt", false)

  def merge!(file : String, mode = :old_first)
    QtDict.load(file).each do |key, vals|
      next if key =~ /\P{Han}/
      @input.upsert(key, vals, mode)
    end
  end

  def gen_from_trad!
    TRADSIM.each do |term|
      next if term.key.size > 0
      next unless vals = @input[term.key]?

      term.vals.each do |simp|
        next if @input.has_key?(simp)
        @input.upsert(simp, vals)
      end
    end
  end

  def save!
    output = Chivi::Library.hanviet

    input = @input.to_a.sort_by(&.[0].size)
    input.each do |(key, vals)|
      next if key.size > 4
      next unless first = vals.first?

      if key.size > 1
        convert = QtUtil.convert(output, key, " ")
        next if first == convert
        pp [key, vals, convert]
      end

      term = Chivi::VpTerm.new(key, vals.uniq.first(3)).tap(&.plock = 3)
      output.upsert(term)
    end

    output.save!(mode: :best)
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
