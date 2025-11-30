Gem::Specification.new do |spec|
  spec.name        = "json_validator_cli"
  spec.version     = "0.1.0"
  spec.summary     = "Simple JSON Schema Draft 7 Validator with CLI"
  spec.authors     = ["Your Name"]
  spec.email       = ["your@email.com"]
  spec.files       = Dir["json_validator_cli/lib/**/*", "json_validator_cli/bin/*"]
  spec.bindir      = "json_validator_cli/bin"
  spec.executables = ["jvc"] 
  
  spec.add_development_dependency "rspec", "~> 3.0"
end
