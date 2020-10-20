require "./filedb/*"

module FileDB
  extend self

  # class_getter book_slug : OldLabelMap { preload("indexes/book_slug") }

  # class_getter zh_author : OldLabelMap { preload("_import/fixes/zh_author") }
  # class_getter vi_author : OldLabelMap { preload("_import/fixes/vi_author") }

  # class_getter zh_title : OldLabelMap { preload("_import/fixes/zh_title") }
  # class_getter vi_title : OldLabelMap { preload("_import/fixes/vi_title") }

  # class_getter zh_genre : OldLabelMap { preload("_import/fixes/zh_genre") }
  # class_getter vi_genre : OldLabelMap { preload("_import/fixes/vi_genre") }
end
