# -*- encoding: utf-8 -*-
# stub: jekyll-loading-lazy 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "jekyll-loading-lazy".freeze
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "bug_tracker_uri" => "https://github.com/gildesmarais/jekyll-loading-lazy/issues" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Gil Desmarais".freeze]
  s.date = "2020-04-21"
  s.description = "Loading Lazy automatically adds loading=\"lazy\" to <img> and <iframe> tags on your Jekyll site.\n".freeze
  s.email = ["jekyll-loading-lazy@desmarais.de".freeze]
  s.homepage = "https://github.com/gildesmarais/jekyll-loading-lazy".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5.8".freeze)
  s.rubygems_version = "3.4.20".freeze
  s.summary = "Automatically adds loading=\"lazy\" to <img> and <iframe> tags.".freeze

  s.installed_by_version = "3.4.20" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<jekyll>.freeze, [">= 3.0", "< 5.0"])
  s.add_runtime_dependency(%q<nokogiri>.freeze, [">= 1.10", "< 2.0"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2.0"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 12.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.0"])
  s.add_development_dependency(%q<rubocop>.freeze, ["< 1.0"])
  s.add_development_dependency(%q<rubocop-jekyll>.freeze, ["< 1.0"])
end
