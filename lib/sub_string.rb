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

  def load_next_block
    if @block
      file.read(BLOCK_SIZE, @block)
    else
      @block = file.read(BLOCK_SIZE)
    end
  end

  def handle_start_of_block
    if @end_of_block_offset
      start_of_block_match = smaller_parts(@target_string)[-@end_of_block_offset][1]
      @occurrences_of_target_string +=1 if @block.rindex(start_of_block_match, @end_of_block_offset) == 0
    end
  end

  def handle_end_of_block
    @target_string_enumerator ||= (1...@target_string.size)
    @target_string_enumerator.each do |offset|
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

  def target_regex
    @target_regex ||= Regexp.new(@target_string)
  end

  # should be "count_occurrences...." or the like
  def find_target_string_in_block
    skip_until = 0
    while index = @block.index(target_regex, skip_until)
      @occurrences_of_target_string +=1
      skip_until = index + @target_string.size
    end
  end
end
