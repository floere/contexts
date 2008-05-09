require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'

task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.spec_opts = %w{--colour --format progress --loadby mtime --reverse}
  t.spec_files = Dir.glob('spec/**/*_spec.rb')
  t.warning = false
end