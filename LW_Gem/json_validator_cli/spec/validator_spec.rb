require "json_validator_cli"

RSpec.describe JsonValidatorCli::Validator do
  let(:schema) do
    {
      "type" => "object",
      "required" => ["name", "age"],
      "properties" => {
        "name" => { "type" => "string" },
        "age"  => { "type" => "integer" }
      }
    }
  end

  it "validates correct data" do
    data = { "name" => "Alice", "age" => 30 }
    validator = described_class.new(schema)
    expect(validator.validate(data)).to be_empty
  end

  it "detects wrong type" do
    data = { "name" => "Alice", "age" => "thirty" } 
    validator = described_class.new(schema)
    errors = validator.validate(data)
    expect(errors.first).to include("Expected type 'integer'")
  end

  it "detects missing required field" do
    data = { "name" => "Alice" } 
    validator = described_class.new(schema)
    errors = validator.validate(data)
    expect(errors.first).to include("Missing required property 'age'")
  end
end
