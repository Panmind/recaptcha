# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{panmind-recaptcha}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marcello Barnaba", "Panmind staff"]
  s.date = %q{2011-09-20}
  s.description = %q{ReCaptcha implements view helpers to generate ReCaptcha code, with the noscript counterpart, required methods that interface with the HTTP API for captcha verification, a DSL to generate a before_filter and the code to implement AJAX captcha validation.}
  s.email = ["vjt@openssl.it", "info@panmind.com"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "README.md",
    "Rakefile",
    "lib/panmind/recaptcha.rb",
    "lib/panmind/recaptcha/railtie.rb",
    "rails/init.rb"
  ]
  s.homepage = %q{http://github.com/Panmind/recaptcha}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{ReCaptcha for Rails - With AJAX Validation}

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.0"])
    else
      s.add_dependency(%q<rails>, ["~> 3.0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.0"])
  end
end

