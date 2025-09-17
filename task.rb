def word_stats(text)
  words = text.split
  word_count = words.length
  longest_word = words.max_by(&:length)
  unique_word_count = words.map(&:downcase).uniq.count

  puts "#{word_count} слів, найдовше: #{longest_word}, унікальних: #{unique_word_count}"
end

puts "Введіть рядок тексту:"
text = gets.chomp

word_stats(text)

# Приклад:
# text = "Ruby is fun and ruby is powerful"
# word_stats(text)
# → 7 слів, найдовше: powerful, унікальних: 5
