@next_turn = false
t = Thread.new do
  while true
    puts 'yay'
    @next_turn = false
    while @next_turn == false
      sleep(1)
    end
  end
end
