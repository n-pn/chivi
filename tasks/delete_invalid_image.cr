INP = "_db/bcover"

Dir.glob(Path[INP, "_output", "*.webp"]).each do |file|
  next unless File.size(file) == 7894
  File.delete(file)
end
