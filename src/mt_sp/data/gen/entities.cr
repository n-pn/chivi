require "../entity"

DIR = "/mnt/devel/Chivi/results/entities"
files = Dir.glob("#{DIR}/*/*.tsv")

output = {} of Tuple(String, String) => SP::Entity

files.each do |file|
  etag = File.basename(file, ".tsv")
  File.each_line(file) do |line|
    form, extra = line.split('\t')

    output[{form, etag}] = SP::Entity.new(form, etag, extra)
  end
end

SP::Entity.upsert(output.values)
