require "../../src/cvmtl/*"

out_vals = CV::VpHint.user_vals
out_tags = CV::VpHint.user_tags

CV::VpDict.load("suggest").list.each do |term|
  next if term._flag > 0 || term.key.size < 1

  hv = CV::MtCore.cv_hanviet(term.key, false)

  vals = term.val.uniq!.reject! do |val|
    val.empty? || val.downcase == hv
  end

  tags = term.attr.split(' ')
    .map! { |x| CV::PosTag.parse(x, term.key).to_str }
    .reject!(&.empty?).uniq!

  out_vals.add(term.key, vals) unless vals.empty?
  out_tags.add(term.key, tags) unless tags.empty?
rescue err
  puts term
  puts err.inspect_with_backtrace
end

out_vals.save!
out_tags.save!
