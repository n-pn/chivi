require "./nv_utils"

module CV::NvFields
  extend self

  DIR = "_db/nv_infos"

  class_getter _index : TokenMap { TokenMap.new "#{DIR}/_index.tsv" }

  class_getter bcover : ValueMap { ValueMap.new "#{DIR}/bcover.tsv" }

  class_getter status : ValueMap { ValueMap.new "#{DIR}/status.tsv" }
  class_getter hidden : ValueMap { ValueMap.new "#{DIR}/hidden.tsv" }

  class_getter yousuu : ValueMap { ValueMap.new "#{DIR}/yousuu.tsv" }
  class_getter origin : ValueMap { ValueMap.new "#{DIR}/origin.tsv" }

  delegate get, to: _index
  delegate each, to: _index

  class_getter bhashes : Array(String) { _index.data.keys }

  def set_status!(bhash : String, value : Int32, force = false)
    return false unless force || value > status.ival(bhash)
    status.set!(bhash, value.to_s)
  end

  def set_hidden!(bhash : String, value : Int32, force = false)
    return false unless force || value > hidden.ival(bhash)
    hidden.set!(bhash, value.to_s)
  end

  def save!(clean : Bool = false)
    @@_index.try(&.save!(clean: clean))
    @@bcover.try(&.save!(clean: clean))

    @@status.try(&.save!(clean: clean))
    @@hidden.try(&.save!(clean: clean))

    @@yousuu.try(&.save!(clean: clean))
    @@origin.try(&.save!(clean: clean))
  end
end
