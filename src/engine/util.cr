require "./util/*"

class Engine
  module Util
    extend self

    # capitalize all words
    def titlecase(input : String)
      input.split(" ").map { |x| capitalize(x) }.join(" ")
    end

    # don't downcase extra characters
    def capitalize(str : String) : String
      return str if str.empty?
      str[0].upcase + str[1..]
    end

    def slugify(input : String, no_accent = false)
      input = unaccent(input) if no_accent

      input.downcase
        .gsub(/[^\p{L}\p{N}_]/, "-")
        .split("-")
        .reject(&.empty?)
        .join("-")
    end

    def unaccent(input : String)
      input
        .tr("áàãạảAÁÀÃẠẢăắằẵặẳĂẮẰẴẶẲâầấẫậẩÂẤẦẪẬẨ", "a")
        .tr("éèẽẹẻEÉÈẼẸẺêếềễệểÊẾỀỄỆỂ", "e")
        .tr("íìĩịỉIÍÌĨỊỈ", "i")
        .tr("óòõọỏOÓÒÕỌỎôốồỗộổÔỐỒỖỘỔơớờỡợởƠỚỜỠỢỞ", "o")
        .tr("úùũụủUÚÙŨỤỦưứừữựửƯỨỪỮỰỬ", "u")
        .tr("ýỳỹỵỷYÝỲỸỴỶ", "y")
        .tr("đĐD", "d")
    end

    # Convert chinese punctuations to english punctuations
    # and full width characters to ascii characters
    def normalize(input : Array(Char)) : Array(Char)
      input.map { |c| NORMALIZE.fetch(c, c) }
    end

    def normalize(input : String) : Array(Char)
      normalize(input.chars)
    end

    # read chinese text file and strip whitespaces
    def read_lines(input : String) : Array(String)
      split_lines(File.read(input))
    end

    # Split text to lines, strip empty whitespaces
    def split_lines(input : String) : Array(String)
      input.split("\n").map(&.tr("　", " ").strip).reject(&.empty?)
    end

    # convert chinese numbers to latin numbers
    def hanzi_int(input)
      HANZI_INT.fetch(input, input)
    end
  end
end
