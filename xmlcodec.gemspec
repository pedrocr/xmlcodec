Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.platform = Gem::Platform::RUBY

  s.name              = 'xmlcodec'
  s.version           = '0.3.1'
  s.date              = '2013-08-30'

  s.summary     = "Generic Importer/Exporter of XML formats"
  s.description = <<EOF
A framework to write object to XML mappers in Ruby that can then function both in whole-document manipulation as well as constant memory unlimited size importing and exporting of XML.
EOF

  s.authors  = ["Pedro Côrte-Real"]
  s.email    = 'pedro@pedrocr.net'
  s.homepage = 'https://github.com/pedrocr/xmlcodec'

  s.require_paths = %w[lib]

  s.has_rdoc = true
  s.rdoc_options = ['-S', '-w 2', '-N', '-c utf8']
  s.extra_rdoc_files = %w[README.rdoc LICENSE]

  s.executables = Dir.glob("bin/*").map{|f| f.gsub('bin/','')}

  s.add_dependency('nokogiri')

  # = MANIFEST =
  s.files = %w[
    LICENSE
    README.rdoc
    Rakefile
    lib/XMLUtils.rb
    lib/element.rb
    lib/stream_object_parser.rb
    lib/stream_parser.rb
    lib/subelements.rb
    lib/xmlcodec.rb
    test/consume_all_as_text_test.rb
    test/element_test.rb
    test/element_types_test.rb
    test/multi_format_test.rb
    test/partial_export_test.rb
    test/partial_import_test.rb
    test/simple_objects.rb
    test/stream_object_parser_test.rb
    test/stream_parser_test.rb
    test/subelements_test.rb
    test/test_helper.rb
    test/utils_test.rb
    xmlcodec.gemspec
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/.*\.rb/ }
end
