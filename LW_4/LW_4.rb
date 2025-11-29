module RecipeCraft
  module UnitConverter
    BASE_UNITS = { mass: :g, volume: :ml, count: :pcs }
    
    TO_BASE = {
      g: { type: :mass, factor: 1 },
      kg: { type: :mass, factor: 1000 },
      ml: { type: :volume, factor: 1 },
      l: { type: :volume, factor: 1000 },
      pcs: { type: :count, factor: 1 }
    }

    def self.to_base(qty, unit)
      unit_sym = unit.to_sym
      raise "Невідома одиниця: #{unit}" unless TO_BASE.key?(unit_sym)

      info = TO_BASE[unit_sym]
      [qty * info[:factor], BASE_UNITS[info[:type]]]
    end

    def self.assert_compatibility(unit1, unit2)
      type1 = TO_BASE[unit1.to_sym][:type]
      type2 = TO_BASE[unit2.to_sym][:type]
      if type1 != type2
        raise "Помилка конвертації: неможливо перевести #{type1} (#{unit1}) в #{type2} (#{unit2}). Маса-Об'єм заборонено."
      end
    end
  end

  class Ingredient
    attr_reader :name, :base_unit, :calories_per_unit

    def initialize(name, unit, calories_per_unit)
      @name = name
      @base_unit = unit.to_sym
      @calories_per_unit = calories_per_unit
    end
  end

  class Recipe
    attr_reader :name, :items

    def initialize(name, items = [])
      @name = name
      @items = items 
    end

    def need
      needed = Hash.new(0)
      @items.each do |item|
        ing = item[:ingredient]
        qty = item[:qty]
        unit = item[:unit]

        UnitConverter.assert_compatibility(unit, ing.base_unit)
        
        base_qty, _ = UnitConverter.to_base(qty, unit)
        needed[ing] += base_qty
      end
      needed
    end
  end

  class Pantry
    def initialize
      @stock = Hash.new { |h, k| h[k] = 0 }
    end

    def add(name, qty, unit)
      base_qty, base_unit = UnitConverter.to_base(qty, unit)
      @stock[name] += base_qty
    end

    def available_for(name)
      @stock[name]
    end
  end

  class Planner
    def self.plan(recipes, pantry, price_list)
      total_needs = Hash.new(0)
      
      recipes.each do |recipe|
        recipe.need.each do |ingredient, qty|
          total_needs[ingredient] += qty
        end
      end

      total_calories = 0
      total_cost = 0

      puts "\n--- ПЛАНУВАННЯ ---"
      puts format("%-15s | %-15s | %-15s | %-15s", "Інгредієнт", "Потрібно", "Є в коморі", "Дефіцит")
      puts "-" * 70

      total_needs.each do |ingredient, needed_qty|
        name = ingredient.name
        have_qty = pantry.available_for(name)
        
        deficit = [needed_qty - have_qty, 0].max
        
        total_calories += needed_qty * ingredient.calories_per_unit

        price_per_unit = price_list[name] || 0
        cost = needed_qty * price_per_unit
        total_cost += cost

        unit_str = ingredient.base_unit.to_s
        
        puts format("%-15s | %-8.1f %-5s | %-8.1f %-5s | %-8.1f %-5s", 
                    name, 
                    needed_qty, unit_str, 
                    have_qty, unit_str, 
                    deficit, unit_str)
      end

      puts "-" * 70
      puts "Total Calories: #{total_calories.round(2)}"
      puts "Total Cost:     #{total_cost.round(2)}"
    end
  end
end

include RecipeCraft

egg    = Ingredient.new("Яйце", :pcs, 72)
milk   = Ingredient.new("Молоко", :ml, 0.06)
flour  = Ingredient.new("Борошно", :g, 3.64)
pasta  = Ingredient.new("Паста", :g, 3.5)
sauce  = Ingredient.new("Соус", :ml, 0.2)
cheese = Ingredient.new("Сир", :g, 4.0)

pantry = Pantry.new
pantry.add("Борошно", 1, :kg)
pantry.add("Молоко", 0.5, :l)
pantry.add("Яйце", 6, :pcs)
pantry.add("Паста", 300, :g)
pantry.add("Сир", 150, :g)

price_list = {
  "Борошно" => 0.02,
  "Молоко"  => 0.015,
  "Яйце"    => 6.0,
  "Паста"   => 0.03,
  "Соус"    => 0.025,
  "Сир"     => 0.08
}

omelet = Recipe.new("Омлет", [
  { ingredient: egg, qty: 3, unit: :pcs },
  { ingredient: milk, qty: 100, unit: :ml },
  { ingredient: flour, qty: 20, unit: :g }
])

pasta_recipe = Recipe.new("Паста", [
  { ingredient: pasta, qty: 200, unit: :g },
  { ingredient: sauce, qty: 150, unit: :ml },
  { ingredient: cheese, qty: 50, unit: :g }
])

recipes_to_cook = [omelet, pasta_recipe]
Planner.plan(recipes_to_cook, pantry, price_list)
