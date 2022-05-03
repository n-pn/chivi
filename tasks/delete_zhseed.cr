require "./shared/bootstrap"

module CV
  def self.delete(bslug, sname)
    return unless nvinfo = Nvinfo.load!(bslug)
    return unless nvseed = Nvseed.find(nvinfo.id, sname)

    puts nvinfo.vname

    nvseed.delete
    nvinfo.update(zseeds: nvinfo.zseeds.reject(&.== nvseed.zseed))
    Nvseed.find(nvinfo.id, 0).try(&.remap!)
  end

  delete ARGV[0], ARGV[1]
end
