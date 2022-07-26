module MtlV2::MTL
  # 代词 - pronoun - đại từ chưa phân loại
  class PronounWord < BaseNode
  end

  # 人称代词 - personal pronoun - đại từ nhân xưng
  class PersproWord < PronounWord
  end

  # 自己
  class ProZiji < PersproWord
  end

  # 指示代词 - demonstrative pronoun - đại từ chỉ thị
  class DemsproWord < Pronoun
  end

  class ProZhe < DemsproWord
  end

  class ProNa1 < DemsproWord
  end

  class ProJi3 < DemsproWord
  end

  # 疑问代词 - interrogative pronoun - đại từ nghi vấn
  class IntrproWord < PronounWord
  end

  class ProNa2 < IntrproWord
  end
end
