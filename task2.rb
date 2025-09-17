def play_game
  secret_number = rand(1..100)
  attempts = 0
  guess = nil

  puts "Комп'ютер загадав число від 1 до 100."

  until guess == secret_number
    attempts += 1
    print "Спроба ##{attempts}. Введіть ваше припущення: "
    guess = gets.chomp.to_i

    if guess < secret_number
      puts "Більше!"
    elsif guess > secret_number
      puts "Менше!"
    else
      puts "Вгадано! Ви вгадали число #{secret_number} за #{attempts} спроб."
    end
  end
end

play_game
