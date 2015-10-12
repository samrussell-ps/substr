class SubString
  BLOCK_SIZE = 1024 * 1024 / 2

  attr_reader :block
  attr_reader :occurrences_of_target_string

  def initialize(filename, target_string)
    @filename = filename
    @target_string = target_string
    @occurrences_of_target_string = 0
  end

  def call
    while @block = load_next_block do
      handle_start_of_block
      find_target_string_in_block
      handle_end_of_block
    end
    @occurrences_of_target_string
  end

  def smaller_parts(input_string)
    @smaller_parts ||= (1...input_string.size).map do |index|
      [input_string[0...index], input_string[index..-1]]
    end
  end

  # load full blocks instead, handle overlaps differently
  #def load_next_block
  #  amount_to_load = BLOCK_SIZE
  #  overlap = @target_string.size - 1
  #  amount_to_load -= overlap if @block
  #  last_bit_of_block = @block ? @block[-overlap..-1] : ''
  #  next_chunk_from_file = file.read(amount_to_load)
  #  @block = next_chunk_from_file ? last_bit_of_block + next_chunk_from_file : nil
  #end

  def load_first_block
    @block = file.read(BLOCK_SIZE)
    start_loader_thread
  end
  
  def load_next_block
    if @block
      Thread.pass while @loader_thread_working
      @block = next_block_from_loader_thread
      kick_loader_thread
      @block
    else
      #load_first_block
      #@block
      file
      start_loader_thread
      Thread.pass while @loader_thread_working
      @block = next_block_from_loader_thread
      kick_loader_thread
      @block
    end
  end

  def start_loader_thread
    @next_block = nil
    @get_next_block = true
    @loader_thread_working = true
    @loader_thread = Thread.new do
      while true
        Thread.pass while @get_next_block == false
        # it breaks if i don't call @file.tell... race condition?
        block_number = @file.tell / BLOCK_SIZE
        puts "Block number #{block_number}" if block_number % 500 == 0
        @next_block = @file.read(BLOCK_SIZE)
        @loader_thread_working = false
        break unless @next_block
        @get_next_block = false
      end
    end
  end

  def kick_loader_thread
    @loader_thread_working = true
    @get_next_block = true
    Thread.pass
  end

  def next_block_from_loader_thread
    @next_block
  end

  def handle_start_of_block
    if @end_of_block_offset
      start_of_block_match = smaller_parts(@target_string)[-@end_of_block_offset][1]
      @occurrences_of_target_string +=1 if @block.rindex(start_of_block_match, @end_of_block_offset) == 0
    end
  end

  def handle_end_of_block
    (1...@target_string.size).each do |offset|
      offset_in_block = @block.size - @target_string.size + offset
      end_of_block_match = smaller_parts(@target_string)[-offset][0]
      if @block.index(end_of_block_match, offset_in_block)
        @end_of_block_offset = offset
        break
      end
    end
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
    while index = @block.index(@target_string, skip_until)
      @occurrences_of_target_string +=1
      #puts "found something at #{index}"
      skip_until = index + @target_string.size
    end
  end

  def string_matches?(base_string, offset, target_string)
  end
end
