# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{legacy_migrations}
  s.version = "0.2.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bernie Telles"]
  s.date = %q{2010-08-25}
  s.description = %q{Rails plugin for transferring or updating data between two db structures.}
  s.email = %q{bernardo.telles@dms.myflorida.com}
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    ".gitignore",
     "MIT-LICENSE",
     "README",
     "Rakefile",
     "VERSION",
     "config/database.yml",
     "install.rb",
     "legacy_migrations.gemspec",
     "lib/legacy_migrations.rb",
     "lib/legacy_migrations/row_matchers.rb",
     "lib/legacy_migrations/source_iterators.rb",
     "lib/legacy_migrations/squirrel.rb",
     "lib/legacy_migrations/squirrel/extensions.rb",
     "lib/legacy_migrations/squirrel/paginator.rb",
     "lib/legacy_migrations/squirrel/squirrel.rb",
     "lib/legacy_migrations/status_report.rb",
     "lib/legacy_migrations/transformations.rb",
     "rails/init.rb",
     "spec/db/schema.rb",
     "spec/db/test.sqlite3",
     "spec/legacy_migrations_spec.rb",
     "spec/lib/transformations_spec.rb",
     "spec/models.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "uninstall.rb"
  ]
  s.homepage = %q{http://github.com/btelles/legacy_migrations}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Rails plugin for transferring or updating data between two db structures.}
  s.test_files = [
    "spec/legacy_migrations_spec.rb",
     "spec/lib/transformations_spec.rb",
     "spec/models.rb",
     "spec/spec_helper.rb",
     "spec/db/schema.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
  end
end

