require "zstd"

module ZstdUtil
  extend self

  def save_io(data : IO | String, out_file : String, level = 3)
    File.open(out_file, "w") do |file|
      Zstd::Compress::IO.open(file, level: level, &.write(data.to_slice))
    end
  end

  def save_ctx(data : IO | String, out_file : String, level = 3)
    cctx = Zstd::Compress::Context.new(level: level)
    File.write(out_file, cctx.compress(data.to_slice))
  end

  def zip_file(inp_file : String, out_file = "#{file}.zst", level = 3)
    cctx = Zstd::Compress::Context.new(level: level)
    ibuf = File.read(inp_file).to_slice
    File.write(out_file, cctx.compress(ibuf))
  end

  def read_file(inp_file : String)
    file = File.open(inp_file, "r")
    Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)
  end

  def load!(file : String)
    if File.exists?(file)
      read_file(inp_file)
    else
      yield.tap { |data| save_ctx(data, file) }
    end
  end
end
