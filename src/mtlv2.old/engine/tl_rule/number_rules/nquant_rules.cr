require "../../mt_util"

module MtlV2::TlRule
  def clean_个!(node : BaseNode) : BaseNode
    if body = node.body?
      deep_clean_个!(body)
    elsif node.key.ends_with?('个')
      if node.key.size > 1 || node.prev?(&.pro_dems?)
        node.val = node.val.sub("cái", "").strip
      end
    end

    node
  end

  def deep_clean_个!(node : BaseNode) : Nil
    loop do
      return node.set!("") if node.key == "个"
      break unless node = node.succ?
    end
  end
end
