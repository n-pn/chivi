require "./src/_data/nv_info"
require "./src/_data/chinfo"

def chap_count(sname, snvid)
  file = "_db/chdata/chorigs/#{sname}/#{snvid}.tsv"
  return 0 unless File.exists?(file)
  return File.read_lines(file).size
end

input = CV::NvValues.source
input.data.each_with_index(1) do |(bhash, seeds), idx|
  chseed = {} of String => Array(String)

  seeds.each do |entry|
    sname, snvid = entry.split("/")

    utime = CV::ChSource.get_utime(sname, snvid)
    utime = (utime / 60).to_i

    total = chap_count(sname, snvid)
    value = [snvid, utime.to_s, total.to_s]

    CV::NvChseed.load(sname).add(bhash, value)
    chseed[sname] = value
  end

  snames = chseed.to_a.sort_by { |(_, arr)| {-arr[2].to_i, -arr[1].to_i} }.map(&.[0])
  CV::NvChseed._index.add(bhash, snames)

  if idx % 100 == 0
    puts "- <#{idx}/#{input.data.size}> #{bhash}"
    CV::NvChseed.save!(mode: :upds)
  end
end

CV::NvChseed.save!
