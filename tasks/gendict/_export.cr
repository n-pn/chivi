require "./shared/*"
require "../../src/engine/convert"

puts "\n[Load deps]".colorize.cyan.bold

class CV::ExportDicts
  LEXICON = ::ValueSet.load(".result/lexicon.tsv", true)
  CHECKED = ::ValueSet.load(".result/checked.tsv", true)

  REJECT_STARTS = File.read_lines("#{__DIR__}/consts/reject-starts.txt")
  REJECT_ENDS   = File.read_lines("#{__DIR__}/consts/reject-ends.txt")

  def should_keep?(key : String, val : String = "")
    return key =~ /\p{Han}/ if key.size == 1
    return false if val =~ /[:(\/{})]/
    # return true if key.ends_with?("目的")
    LEXICON.includes?(key) || CHECKED.includes?(key)
  end

  def should_reject?(key : String)
    REJECT_STARTS.each { |word| return true if key.starts_with?(word) }
    REJECT_ENDS.each { |word| return true if key.ends_with?(word) }

    key !~ /\p{Han}/
  end

  getter out_regular : VpDict = VpDict.load("regular", reset: true)
  getter out_various : VpDict = VpDict.load("various", reset: true)
  getter out_suggest : VpDict = VpDict.load("suggest", reset: true)

  getter cv_hanviet : Convert { Convert.hanviet }
  getter cv_regular : Convert { Convert.new(@out_regular) }

  def match_convert?(key : String, val : String)
    return false if cv_hanviet.translit(key, false).to_s == val
    convert = cv_regular.tl_plain(key).downcase
    convert == val
  end

  def export_regular!
    puts "\n[Export regular]".colorize.cyan.bold

    input = QtDict.load(".result/regular.txt", true)
    input.to_a.sort_by(&.[0].size).each do |key, vals|
      next unless value = vals.first?
      next if value.empty?

      match = value.downcase
      unless should_keep?(key, value)
        next if should_reject?(key)
        next if match_convert?(key, match)
      end

      @out_regular.put(key, vals)
    end

    puts "\n- load hanviet".colorize.cyan.bold

    CV::VpDict.hanviet.trie.each do |term|
      next if term.key.size > 1 || @out_regular.find(term.key)
      @out_regular.put(term.key, term.vals)
    end

    @out_regular.load!("_db/dictdb/remote/common/regular.tab")
    @out_regular.save!
  end

  def export_uniques!
    puts "\n[Export uniques]".colorize.cyan.bold

    Dir.glob("_db/dictdb/remote/unique/*.tab").each do |file|
      dict = VpDict.load(File.basename(file, ".tab"))
      dict.load!(file)
      dict.save!(trim: true)

      dict.trie.each do |term|
        # add to quick translation dict if entry is a name
        unless term.key.size < 3 && term.vals.empty? || term.vals[0].downcase == term.vals[0]
          various_term = @out_various.gen_term(term.key, term.vals)
          @out_various.add(various_term)
        end

        # add to suggestion
        suggest_term = @out_suggest.gen_term(term.key, term.vals)
        if old_term = @out_suggest.find(term.key)
          suggest_term.vals.concat(old_term.vals).uniq!
        end

        @out_suggest.add(suggest_term)
      end
    end
  end

  def export_suggest!
    puts "\n[Export suggest]".colorize.cyan.bold

    inp_suggest = ::QtDict.load(".result/suggest.txt", true)
    inp_suggest.to_a.sort_by(&.[0].size).each do |key, vals|
      next unless value = vals.first?

      next if value.empty?
      match = value.downcase

      unless should_keep?(key, value)
        next if should_reject?(key)
        next if key =~ /[的了是]/
        next if match_convert?(key, match)
      end

      out_suggest.put(key, vals)
    rescue err
      pp [err, key, vals]
    end

    out_suggest.save!(trim: true)
  end

  def export_various!
    puts "\n[Export various]".colorize.cyan.bold

    inp_various = ::QtDict.load(".result/various.txt", true)
    inp_various.to_a.sort_by(&.[0].size).each do |key, vals|
      next if key.size < 2 || key.size > 6
      unless should_keep?(key, vals.first)
        next if should_reject?(key)
      end

      out_various.put(key, vals)
    end

    out_various.save!(trim: true)
  end
end

tasks = CV::ExportDicts.new

tasks.export_regular!
tasks.export_uniques!
tasks.export_suggest!
tasks.export_various!

# puts "\n[Export recycle]".colorize.cyan.bold

# inp_recycle = QtDict.load(".result/recycle.txt", true)
# out_recycle = CV::VpDict.load("salvation", 0)

# inp_recycle.to_a.sort_by(&.[0].size).each do |key, vals|
#   unless should_keep?(key)
#     next if should_skip?(key)
#   end

#   out_recycle.add(key, vals)
# end
# out_recycle.save!
