# require "../../data/sq_defn"

# class MT::WsegDict
#   class_getter essence : self { load!("essence") }
#   class_getter regular : self { load!("regular") }
#   class_getter suggest : self { load!("suggest") }

#   class_getter nqnt_vi : self { load!("nqnt_vi") }
#   class_getter word_hv : self { load!("word_hv") }
#   class_getter name_hv : self { load!("name_hv") }

#   CACHE = {} of String => self

#   def self.load!(name : String) : self
#     CACHE[name] ||= new(name)
#   end

#   @[AlwaysInline]
#   def self.add_defn(dname : String, input : SqDefn)
#     return unless dict = CACHE[dname]?
#     input.dnum < 0 ? dict.delete(input) : dict.add(input)
#   end

#   @[AlwaysInline]
#   def self.del_defn(dname : String, input : SqDefn) : Nil
#     CACHE[dname]?.try(&.delete(input))
#   end

#   getter name : String
#   getter root = Trie.new
#   getter size = 0
#   getter d_id : Int32

#   def initialize(@name, reset : Bool = false)
#     @d_id = MtDtyp.map_id(name)
#     return if reset
#     time = Time.measure { self.load_from_db3!(@d_id) }
#     Log.info { "loading [#{name}]: #{time.total_milliseconds}ms, total: #{@size}" }
#   end

#   def load_from_db3!(d_id = @d_id)
#     SqDefn.query_each(d_id) do |zstr, defn|
#       self[zstr].set(defn) { DefnData.calc_prio(zstr.size) }
#       @size &+= 1
#     end
#   end

#   @[AlwaysInline]
#   def add(defn : SqDefn)
#     self.add(defn.zstr, DefnData.new(defn))
#   end

#   @[AlwaysInline]
#   def add(zstr : String, defn : DefnData)
#     self[zstr].set(defn) { DefnData.calc_prio(zstr.size) }
#   end

#   @[AlwaysInline]
#   def delete(defn : SqDefn)
#     self.delete(defn.zstr, MtEpos.from_value(defn.epos))
#   end

#   @[AlwaysInline]
#   def delete(zstr : String, epos : MtEpos)
#     self[zstr]?.try(&.delete(epos))
#   end

#   ####

#   def [](zstr : String)
#     zstr.each_char.reduce(self.root) do |node, char|
#       succ = node.succ ||= {} of Char => Trie
#       # char = char - 32 if 'ａ' <= char <= 'ｚ'debug
#       succ[char] ||= Trie.new
#     end
#   end

#   def []?(zstr : String)
#     node = self.root

#     zstr.each_char do |char|
#       return unless succ = node.succ
#       char = char - 32 if 'ａ' <= char <= 'ｚ'
#       return unless node = succ[char]?
#     end

#     node
#   end

#   @[AlwaysInline]
#   def get_defn?(zstr : String, cpos : String)
#     get_defn?(zstr: zstr, epos: MtEpos.parse(cpos))
#   end

#   @[AlwaysInline]
#   def get_defn?(zstr : String, epos : MtEpos)
#     self[zstr]?.try(&.get_defn?(epos))
#   end

#   @[AlwaysInline]
#   def any_defn?(zstr : String)
#     self[zstr]?.try(&.get_top)
#   end

#   def scan_wseg(input : Array(Char), start : Int32 = 0, &)
#     node = @root

#     start.upto(input.size &- 1) do |index|
#       char = input.unsafe_fetch(index)
#       # char = CharUtil.to_canon(char, true)
#       char = char - 32 if 'ａ' <= char <= 'ｚ'
#       break unless node = node.succ.try(&.[char]?)
#       yield index &- start &+ 1, node.prio if node.prio >= 0
#     end
#   end

#   ####

#   class Trie
#     property prio : Int16 = -1_i16
#     property succ : Hash(Char, self)? = nil
#     property data : Array(DefnData) | DefnData | Nil = nil

#     def set(defn : DefnData, &) : Nil
#       @prio = yield if @prio < 0

#       case data = @data
#       in Nil
#         @data = defn
#       in Array
#         if index = data.index(&.epos.== defn.epos)
#           data[index] = defn
#         else
#           data << defn
#         end
#         data.sort_by!(&.rank.-)
#       in DefnData
#         if defn.epos == data.epos
#           @data = defn
#         elsif defn.rank >= data.rank
#           @data = [defn, data]
#         else
#           @data = [data, defn]
#         end
#       end
#     end

#     def delete(epos : MtEpos)
#       case data = @data
#       in Nil then return
#       in DefnData
#         return unless data.epos == epos

#         @data = nil
#         @prio = -1_i16 if @prio > 0
#       in Array
#         data.reject!(&.epos.== epos)
#         @data = data.first if data.size == 1
#       end
#     end

#     @[AlwaysInline]
#     def get(cpos : String)
#       get(epos: MtEpos.parse(cpos))
#     end

#     def get(epos : MtEpos) : {DefnData?, DefnData?}
#       case data = @data
#       in Nil then {nil, nil}
#       in DefnData
#         data.rank > 2 || epos == data.epos ? {data, nil} : {nil, data}
#       in Array
#         head = data.first
#         head.rank > 2 ? {head, nil} : {data.find(&.epos.== epos), head}
#       end
#     end

#     def get_top
#       case data = @data
#       in Nil      then nil
#       in DefnData then data
#       in Array    then data.first
#       end
#     end
#   end
# end
