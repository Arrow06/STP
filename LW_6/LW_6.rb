sum3 = ->(a, b, c) { a + b + c }

def curry3(fn)
  target_arity = 3

  wrapper = ->(stored_args) do
    ->(*new_args) do
      all_args = stored_args + new_args

      if all_args.size >= target_arity
        if all_args.size > target_arity
          raise ArgumentError, "wrong number of arguments (given #{all_args.size}, expected #{target_arity})"
        end
        
        fn.call(*all_args)
      else
        wrapper.call(all_args)
      end
    end
  end

  wrapper.call([])
end

puts "--- Тест 1: sum3 ---"
cur = curry3(sum3)

p cur.call(1).call(2).call(3)
p cur.call(1, 2).call(3)    
p cur.call(1).call(2, 3)
p cur.call(1, 2, 3) 

p cur.call().call(1).call(2, 3)

begin
  cur.call(1, 2, 3, 4)
rescue ArgumentError => e
  puts "Error caught: #{e.message}"
end


puts "\n--- Тест 2: String concatenation ---"
f = ->(a, b, c) { "#{a}-#{b}-#{c}" }
cF = curry3(f)

p cF.call('A').call('B', 'C')   
p cF.call('A', 'B', 'C')
