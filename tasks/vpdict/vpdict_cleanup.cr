require "../../src/libcv/*"

def cleanup(vdict : CV::VpDict)
  count = 0

  vdict.data.each do |term|
    next unless term.deleted?
    term._flag = 2
    count += 1
  end

  return if count == 0
  puts "- count: #{count}"
  vdict.save!(save_log: true)
end

cleanup("regular")

CV::VpDict.nvdicts.each { |bdict| cleanup(CV::VpDict.load_novel(bdict)) }
