require "./utils/common"
require "./utils/clavis"

require "../../src/engine/library"
require "../../src/kernel/mapper/old_value_set"

CRUCIAL = ValueSet.read!(Utils.inp_path("autogen/crucial-chars.txt"))
HANZIDB = ValueSet.read!(Utils.inp_path("initial/hanzidb.txt"))

TRADSIM = Engine::BaseDict.tradsim
BINH_AM = Engine::BaseDict.binh_am

def should_keep_hanviet?(input : String)
  return true if CRUCIAL.includes?(input)
  return true if HANZIDB.includes?(input)

  input.split("").each do |char|
    return false if TRADSIM.has_key?(char)
  end

  true
end

def merge(dict : Engine::BaseDict, file : String, mode = :old_first)
  input = Clavis.load(file)

  input.each do |key, vals|
    next if key =~ /\P{Han}/

    dict.upsert(key) do |node|
      if node.removed?
        node.vals = vals
      else
        case mode
        when :keep_old
          # do nothing
        when :keep_new
          node.vals = vals
        when :old_first
          node.vals.concat(vals).uniq!
        when :new_first
          node.vals = vals.concat(node.vals).uniq!
        when :first_if_exists
          if node.vals.includes?(vals.first)
            node.vals = vals.concat(node.vals).uniq!
          else
            node.vals.concat(vals).uniq!
          end
        end
      end

      node.vals.concat(vals).uniq!
    end
  end

  dict
end

def transform_from_trad!(dict : Engine::BaseDict)
  HANZIDB.each do |key|
    next unless trad = TRADSIM.find(key)
    next unless item = dict.find(key)

    dict.upsert(trad.vals.first) do |node|
      break unless node.vals.empty?
      node.vals = item.vals
      puts item
    end
  end

  dict
end

def extract_conflicts(dict)
  conflict = Clavis.load("hanviet/conflict.txt", false)
  resolved = Clavis.load("hanviet/verified-chars.txt", true)
  # lacviet = Clavis.load("localqt/hanviet.txt", true)

  dict.each do |node|
    next if node.vals.size < 2
    next unless CRUCIAL.includes?(node.key)
    next if resolved.has_key?(node.key)
    conflict.upsert(node.key, node.vals)
  end

  conflict.save!
end

def save_dict!(dict)
  CRUCIAL.each do |key|
    next if dict.has_key?(key)
    puts "#{key}="
  end

  dict.save!
end

hanviet = Engine::BaseDict.load("core/hanviet", mode: 0)

hanviet = merge(hanviet, "localqt/hanviet.txt", mode: :old_first)
hanviet = merge(hanviet, "hanviet/checked-chars.txt", mode: :old_first)
hanviet = merge(hanviet, "hanviet/lacviet-chars.txt", mode: :old_first)
hanviet = merge(hanviet, "hanviet/trichdan-chars.txt", mode: :old_first)
hanviet = merge(hanviet, "hanviet/verified-chars.txt", mode: :keep_new)

hanviet = merge(hanviet, "hanviet/lacviet-words.txt", mode: :old_first)
hanviet = merge(hanviet, "hanviet/trichdan-words.txt", mode: :old_first)
hanviet = merge(hanviet, "hanviet/verified-words.txt", mode: :keep_new)

extract_conflicts(hanviet)
hanviet.save!
