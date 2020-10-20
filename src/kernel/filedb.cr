require "./filedb/*"

module FileDB
  extend self

  # class_getter book_slug : LabelMap { preload("indexes/book_slug") }

  # class_getter zh_author : LabelMap { preload("_import/fixes/zh_author") }
  # class_getter vi_author : LabelMap { preload("_import/fixes/vi_author") }

  # class_getter zh_title : LabelMap { preload("_import/fixes/zh_title") }
  # class_getter vi_title : LabelMap { preload("_import/fixes/vi_title") }

  # class_getter zh_genre : LabelMap { preload("_import/fixes/zh_genre") }
  # class_getter vi_genre : LabelMap { preload("_import/fixes/vi_genre") }
end
