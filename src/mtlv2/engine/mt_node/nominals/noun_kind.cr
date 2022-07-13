module MtlV2::MTL
  @[Flags]
  enum NounKind
    # https://khoahoctiengtrung.com/danh-tu-trong-tieng-trung/

    # # in rules

    Ktetic # possessives noun
    Locale # place or location

    # 专有名词
    # https://baike.baidu.com/item/%E4%B8%93%E6%9C%89%E5%90%8D%E8%AF%8D/3543467
    Proper

    Person # noun refer human
    Living # animate noun

    # # future

    # 个体名词 individual noun
    # https://baike.baidu.com/item/%E4%B8%AA%E4%BD%93%E5%90%8D%E8%AF%8D/2894284
    Individ

    # 集体名词 collective Noun
    # https://baike.baidu.com/item/%E9%9B%86%E4%BD%93%E5%90%8D%E8%AF%8D/4368019
    Collect

    # 抽象名词
    # https://baike.baidu.com/item/%E6%8A%BD%E8%B1%A1%E5%90%8D%E8%AF%8D/417488
    Abstract

    # 物质名词
    # https://baike.baidu.com/item/%E7%89%A9%E8%B4%A8%E5%90%8D%E8%AF%8D/10670685
    Material
  end
end
