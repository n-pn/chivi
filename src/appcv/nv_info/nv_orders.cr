require "./nv_utils"

module CV::NvOrders
  extend self

  DIR = "_db/nvdata"

  ORDERS = {"access", "update", "voters", "rating", "weight"}

  {% for label in ORDERS %}
    class_getter {{label.id}} : OrderMap do
      OrderMap.new("#{DIR}/#{{{ label }}}.tsv")
    end
  {% end %}

  def get(type = "weight")
    case type
    when "access" then access
    when "update" then update
    when "rating" then rating
    when "voters" then voters
    else               weight
    end
  end

  def set_access!(bhash : String, value : Int64, force : Bool = false)
    return false unless force || value > access.ival_64(bhash)
    access.set!(bhash, value)
  end

  def set_update!(bhash : String, value : Int64, force : Bool = false)
    return false unless force || value > update.ival_64(bhash)
    update.set!(bhash, value)
  end

  def set_scores!(bhash : String, voters_val : Int32, rating_val : Int32)
    weight_val = voters_val * rating_val

    if voters_val < 25
      weight_val += (25 - voters_val) + Random.rand(40..60)
      rating_val = weight_val // 25
    end

    voters.set!(bhash, voters_val)
    rating.set!(bhash, rating_val)
    weight.set!(bhash, weight_val)
  end

  def save!(clean : Bool = false)
    {% for type in ORDERS %}
      @@{{ type.id }}.try(&.save!(clean: clean))
    {% end %}
  end
end
