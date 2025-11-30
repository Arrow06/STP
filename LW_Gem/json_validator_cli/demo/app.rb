require "json_validator_cli"

puts "=== Demo App: Recipe Validation ==="

recipe_schema = {
  "type" => "object",
  "required" => ["title", "cooking_time_min"],
  "properties" => {
    "title" => { "type" => "string" },
    "cooking_time_min" => { "type" => "integer" },
    "vegetarian" => { "type" => "boolean" }
  }
}

bad_recipe = {
  "title" => "Borscht",
  "cooking_time_min" => 90, 
  "vegetarian" => true
}

puts "\nValidating recipe..."
validator = JsonValidatorCli::Validator.new(recipe_schema)
errors = validator.validate(bad_recipe)

if errors.empty?
  puts "Recipe is valid!"
else
  puts "Recipe is invalid! Errors found:"
  puts errors
end
