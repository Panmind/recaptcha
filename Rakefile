require 'rake'
require 'rake/rdoctask'

require 'lib/panmind/recaptcha'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name             = 'panmind-recaptcha'

    gemspec.summary          = 'ReCaptcha for Rails - With AJAX Validation'
    gemspec.description      = 'ReCaptcha implements view helpers to generate ReCaptcha code, '     \
                               'with the noscript counterpart, required methods that interface ' \
                               'with the HTTP API for captcha verification, a DSL to generate a '  \
                               'before_filter and the code to implement AJAX captcha validation.'

    gemspec.authors          = ['Marcello Barnaba']
    gemspec.email            = 'vjt@openssl.it'
    gemspec.homepage         = 'http://github.com/Panmind/recaptcha'

    gemspec.files            = %w( README.md Rakefile rails/init.rb ) + Dir['lib/**/*']
    gemspec.extra_rdoc_files = %w( README.md )
    gemspec.has_rdoc         = true

    gemspec.version          = Panmind::Recaptcha::Version
    gemspec.date             = '2010-11-17'

    gemspec.require_path     = 'lib'

    gemspec.add_dependency('rails', '~> 2.3.8')
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: gem install jeweler'
end

desc 'Generate the rdoc'
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.add %w( README.md lib/**/*.rb )

  rdoc.main  = 'README.md'
  rdoc.title = 'ReCaptcha for Rails - With AJAX Validation'
end

desc 'Will someone help write tests?'
task :default do
  puts
  puts 'Can you help in writing tests? Please do :-)'
  puts
end
