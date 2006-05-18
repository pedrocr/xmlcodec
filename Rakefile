PKG_NAME = 'xmlcodec'
PKG_VERSION = '0.0.2'

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rubygems'

task :default => ['test']

TEST_FILES = 'test/**/*.rb'
CODE_FILES = 'lib/**/*.rb'

PKG_FILES = FileList[TEST_FILES,
                     CODE_FILES,
                     'README*',
                     'LICENSE',
                     'Rakefile']

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Generic Importer/Exporter of XML formats"
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.author = 'Pedro Côrte-Real'
  s.email = 'pedrocr@gmail.com'
  s.requirements << 'none'
  s.require_path = 'lib'
  s.autorequire = 'rake'
  s.files = PKG_FILES
  s.description = <<EOF
A library that eases the creation of XML importers and exporters for ruby.
EOF
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/Test*.rb']
  t.libs = ['../lib','..']
  t.ruby_opts = ['-xtest']
  t.verbose = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README"
  rd.name = :docs
  rd.rdoc_files.include("README", "lib/**/*.rb")
  rd.rdoc_dir = 'doc'
  rd.title = "#{PKG_NAME} API"
  rd.options = ['-S', '-w 2', '-N']
end

task :stats do
  code_code, code_comments = count_lines(FileList[CODE_FILES])
  test_code, test_comments = count_lines(FileList[TEST_FILES])
  
  puts "Code lines: #{code_code} code, #{code_comments} comments"
  puts "Test lines: #{test_code} code, #{test_comments} comments"
  
  ratio = test_code.to_f/code_code.to_f
  
  puts "Code to test ratio: 1:%.2f" % ratio
end

def count_lines(files)
  code = 0
  comments = 0
  files.each do |f| 
    File.open(f).each do |line|
      if line.strip[0] == '#'[0]
        comments += 1
      else
        code += 1
      end
    end
  end
  [code, comments]
end
