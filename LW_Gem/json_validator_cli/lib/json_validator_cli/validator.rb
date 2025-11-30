module JsonValidatorCli
  class Validator
    def initialize(schema)
      @schema = schema
    end

    def validate(data)
      validate_node(data, @schema, "root")
    end

    private

    def validate_node(data, schema, path)
      errors = []

      if schema.key?("type")
        errors += check_type(data, schema["type"], path)
      end

      if schema.key?("required") && data.is_a?(Hash)
        schema["required"].each do |field|
          unless data.key?(field)
            errors << "Error at #{path}: Missing required property '#{field}'"
          end
        end
      end

      if schema.key?("properties") && data.is_a?(Hash)
        schema["properties"].each do |key, sub_schema|
          if data.key?(key)
            errors += validate_node(data[key], sub_schema, "#{path}.#{key}")
          end
        end
      end

      errors
    end

    def check_type(value, expected_type, path)
      valid = case expected_type
              when "string"  then value.is_a?(String)
              when "integer" then value.is_a?(Integer)
              when "number"  then value.is_a?(Numeric)
              when "boolean" then [true, false].include?(value)
              when "array"   then value.is_a?(Array)
              when "object"  then value.is_a?(Hash)
              when "null"    then value.nil?
              else true
              end
      
      valid ? [] : ["Error at #{path}: Expected type '#{expected_type}', got #{value.class}"]
    end
  end
end
