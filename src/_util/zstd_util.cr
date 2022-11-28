require "zstd"

module ZstdUtil
  extend self

  def save_io(data : IO | String, out_file : String, level = 3)
    file = File.open(out_file, "w")
    Zstd::Compress::IO.open(file, sync_close: true, level: level) do |cio|
      cio.write data.to_slice
    end
  end

  def save_ctx(data : IO | String, out_file : String, level = 3)
    cctx = Zstd::Compress::Context.new(level: level)
    File.write(out_file, cctx.compress(data.to_slice))
  end

  def save_file(inp_file : String, out_file = "#{file}.zst", level = 3)
    cctx = Zstd::Compress::Context.new(level: level)
    ibuf = File.read(inp_file).to_slice
    File.write(out_file, cctx.compress(ibuf))
  end

  def read_file(inp_file : String)
    file = File.open(inp_file, "r")
    Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)
  end
end
