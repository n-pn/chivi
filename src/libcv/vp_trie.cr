module VP
  class Trie(T)
    property data : T? = nil
    getter _next = Hash(Char, Trie(T)).new

    def each : Nil
      queue = [self]

      while node = queue.shift?
        node.data.try { |x| yield x }
        node._next.each_value { |x| queue << x }
      end
    end

    def dig(key : String) : Trie(T)?
      node = self
      key.each_char { |c| return unless node = node._next[c]? }
      node
    end

    def dig(key : Array(Char)) : Trie(T)?
      node = self
      key.each { |c| return unless node = node._next[c]? }
      node
    end

    def dig!(key : String) : Trie(T)
      node = self
      key.each_char { |c| node = node._next[c] ||= Trie(T).new }
      node
    end

    def get(key : String | Array(Char)) : T?
      dig(key).try(&.data)
    end

    def get_all(chars : Array(Char), index : Int32 = 0) : Nil
      node = self

      (index...chars.size).each do |i|
        char = chars.unsafe_fetch(i)
        break unless node = node._next[char]?
        node.data.try { |x| yield x }
      end
    end

    def add(key : String, data : T) : Nil
      dig!(key).data = data
    end
  end
end
