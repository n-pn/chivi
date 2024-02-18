require "zstd"

module ZstdUtil
  def self.save_io(data : IO | String, out_file : String, level = 3)
    File.open(out_file, "w") do |file|
      Zstd::Compress::IO.open(file, level: level, &.write(data.to_slice))
    end
  end

  def self.save_ctx(data : IO | String, out_file : String, level = 3)
    cctx = Zstd::Compress::Context.new(level: level)
    File.write(out_file, cctx.compress(data.to_slice))
  end

  def self.zip_file(inp_file : String, out_file = "#{file}.zst", level = 3)
    cctx = Zstd::Compress::Context.new(level: level)
    ibuf = File.read(inp_file).to_slice
    File.write(out_file, cctx.compress(ibuf))
  end

  def self.read_file(inp_file : String)
    file = File.open(inp_file, "r")
    Zstd::Decompress::IO.open(file, sync_close: true, &.gets_to_end)
  end

  def self.unzip_file(zst_path : String, out_path = zst_path.rstrip(".zst"))
    file = File.open(zst_path, "rb")
    Zstd::Decompress::IO.open(file, sync_close: true) do |zst_io|
      File.open(out_path, "wb") { |out_io| IO.copy(zst_io, out_io) }
    end
  end

  def self.load!(file : String, &)
    if File.exists?(file)
      read_file(inp_file)
    else
      yield.tap { |data| save_ctx(data, file) }
    end
  end
end
