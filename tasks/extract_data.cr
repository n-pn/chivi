require "../src/_init/ysbook_init"
require "./nvseed/ysbook_data"

module CV
  INP = "var/ysbooks"
  OUT = "var/nvinfos/ysbooks"

  Dir.each_child(INP) do |child|
    group = child.to_i.to_s
    inp_dir = File.join(INP, child)

    output = YsbookData.new File.join(OUT, group)
    snvids = Dir.children(inp_dir).map { |x| File.basename(x, ".json") }

    snvids.sort_by(&.to_i).each do |snvid|
      file = File.join(inp_dir, "#{snvid}.json")
      entry = YsbookInit.from_json File.read(file)
      atime = File.info(file).modification_time.to_unix

      output.add!(entry, snvid, atime)
    end

    output.save!(clean: true)
  end
end
