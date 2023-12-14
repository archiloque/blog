require 'set'

# @param [String] map
def process(map)
  number_of_keys = map.count('a-z')
  all_keys_mask = 0
  1.upto(number_of_keys) do |key_number|
    all_keys_mask += (1 << (key_number - 1))
  end
  map = map.split("\n")
  map_width = map.first.length
  map_height = map.length
  # All positions already visited
  # each contain a Set with the list of key combinations
  visited_positions = Hash.new { |hash, key| hash[key] = Set.new }
  entrance_line = map.index { |l| l.include?('@') }
  entrance_column = map[entrance_line].index('@')
  map[entrance_line][entrance_column] = '.'
  positions_to_explore = []
  positions_to_explore << {
      line: entrance_line,
      column: entrance_column,
      keys: 0,
      number_of_steps: 0
  }
  until positions_to_explore.empty?
    position_to_explore = positions_to_explore.shift
    [{delta_line: -1, delta_column: 0},
     {delta_line: 1, delta_column: 0},
     {delta_line: 0, delta_column: 1},
     {delta_line: 0, delta_column: -1}].each do |direction|
      target_line = position_to_explore[:line] + direction[:delta_line]
      target_column = position_to_explore[:column] + direction[:delta_column]
      target_keys = position_to_explore[:keys]
      target_map_item = map[target_line][target_column]
      # p "Trying (#{target_line}, #{target_column}) with content [#{target_map_item}] and keys [#{target_keys}]"
      if target_map_item == '#'
        # p "Wall"
        next
      end

      target_map_item_ascii = target_map_item.ord
      if (target_map_item_ascii >= 97) && (target_map_item_ascii <= 122)
        # p "Key"
        key_index = target_map_item_ascii - 97
        if (target_keys & (1 << key_index)) == 0
          # p "Fetch the key"
          target_keys += (1 << key_index)
          if target_keys == all_keys_mask
            # p "Found all the keys !"
            return position_to_explore[:number_of_steps] + 1
          end
        end
      elsif (target_map_item_ascii >= 65) && (target_map_item_ascii <= 90)
        require_key_index = target_map_item_ascii - 65
        unless (target_keys & (1 << require_key_index)) != 0
          # p "Miss the key"
          next
        end
      end

      unless visited_positions[(target_line * map_width) + target_column].add?(target_keys)
        next
      end

      positions_to_explore << {
          line: target_line,
          column: target_column,
          keys: target_keys,
          number_of_steps: position_to_explore[:number_of_steps] + 1
      }
    end
  end
end
