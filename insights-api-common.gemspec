$:.push File.expand_path("lib", __dir__)
require "insights/api/common/version"

Gem::Specification.new do |spec|
  spec.name          = "insights-api-common"
  spec.version       = Insights::API::Common::VERSION
  spec.authors       = ["Insights Authors"]

  spec.summary       = %q{Common Utilites for Insights microservices}
  spec.description   = %q{Header, Encryption, RBAC, Serialization, Pagination and other common behavior for Insights microservices built with Rails}
  spec.homepage      = "https://github.com/RedHatInsights/insights-api-common-rails.git"
  spec.licenses      = ["Apache-2.0"]

  spec.files = Dir["{app,config,db,lib,spec/support}/**/*", "LICENSE.txt", "Rakefile", "README.md"]

  spec.add_runtime_dependency "acts_as_tenant"
  spec.add_runtime_dependency "manageiq-password", "~>0.1"
  spec.add_runtime_dependency "pg",                "> 0"
  spec.add_runtime_dependency "rails",             ">= 5.2.1.1", "~> 5.2"

  # For Insights::API::Common::Logging
  spec.add_runtime_dependency "manageiq-loggers", "~> 0.3"
  spec.add_runtime_dependency "cloudwatchlogger", "~> 0.2"

  # For Insights::API::Common::Metrics
  spec.add_runtime_dependency "prometheus_exporter", "~> 0.4.5"

  # For Insights::API::Common::OpenApi
  spec.add_runtime_dependency "more_core_extensions"
  spec.add_runtime_dependency "openapi_parser",      "~> 0.6.1"

  # For Insights::API::Common::GraphQL
  spec.add_runtime_dependency "graphql",         "~> 1.9"
  spec.add_runtime_dependency "graphql-batch",   "~> 0.4"
  spec.add_runtime_dependency "graphql-preload", "~> 2.0", "< 2.1"
  spec.add_runtime_dependency "query_relation"

  spec.add_development_dependency "factory_bot"
  spec.add_development_dependency "rake",        "~> 10.0"
  spec.add_development_dependency "rspec",       "~> 3.0"
  spec.add_development_dependency "rspec-mocks"
  spec.add_development_dependency "rspec-rails", "~> 3.8"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock"
end
