class SubString
  BLOCK_SIZE = 1024 * 1024

  attr_reader :block
  attr_reader :occurrences_of_target_string

  def initialize(filename, target_string)
    @filename = filename
    @target_string = target_string
    @occurrences_of_target_string = 0
  end

  def call
    while @block = load_next_block do
      find_target_string_in_block
    end
    @occurrences_of_target_string
  end

  def load_next_block
    amount_to_load = BLOCK_SIZE
    overlap = @target_string.size - 1
    amount_to_load -= overlap if @block
    last_bit_of_block = @block ? @block[-overlap..-1] : ''
    next_chunk_from_file = file.read(amount_to_load)
    @block = next_chunk_from_file ? last_bit_of_block + next_chunk_from_file : nil
  end

  def file
    @file ||= File.open(@filename, 'r')
  end

  # should be "count_occurrences...." or the like
  def find_target_string_in_block
    #target_string_start_points_in_block = (0..block.size-@target_string.size)
    skip_until = 0
    #target_string_start_points_in_block.each do |start_point|
    #  next if start_point < skip_until
    #  string_to_compare = block[start_point...start_point+@target_string.size]
    #  if string_to_compare == @target_string
    #    @occurrences_of_target_string += 1
    #    skip_until = start_point + @target_string.size
    #  end
    #end
    while index = block.index(@target_string, skip_until)
      @occurrences_of_target_string +=1
      skip_until = index + @target_string.size
    end
  end

  def string_matches?(base_string, offset, target_string)
  end
end
