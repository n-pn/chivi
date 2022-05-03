require "tabkv"

OLD = "var/ysinfos/yscrits.old"
DIR = "var/ysinfos/yscrits"

Dir.glob("#{DIR}/*-ztext.tsv") do |file|
  target = Tabkv(Array(String)).new(file)

  source = Tabkv(Array(String)).new(file.sub(DIR, OLD))

  target.data.each do |y_cid, intro|
    next unless intro == ["$$$"]

    if prev_intro = source[y_cid]?
      target.append(y_cid, prev_intro)
    end
  end

  target.save!(clean: true)
end
