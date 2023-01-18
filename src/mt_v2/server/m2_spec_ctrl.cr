require "./_m2_ctrl_base"

class M2::SpecCtrl < AC::Base
  base "/_m2"

  SPEC_DIR = "var/mt_v2/tests/"

  @[AC::Route::GET("/specs")]
  def list_specs
    files = Dir.glob("#{SPEC_DIR}**/*.tsv").map!(&.sub(SPEC_DIR, "").sub(".tsv", ""))
    render json: files.reject!(&.includes?('_'))
  end

  MTL = M2::Engine.new("combine")

  @[AC::Route::GET("/specs/:fname")]
  def spec_file(fname : String)
    lines = File.read_lines("#{SPEC_DIR}#{fname}.tsv").reject! { |x| x.empty? || x[0] == '#' }

    entry = lines.compact_map do |line|
      rows = line.split('\t')
      next if rows.size < 2

      {
        input:  rows[0],
        expect: rows[1..],
        actual: MTL.cv_plain(rows[0]).to_txt(apply_cap: false),
      }
    end

    render json: entry
  end
end
