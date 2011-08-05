# -*- mode:ruby; -*-

require 'fileutils'
require 'rake'
require 'socket'
require 'rake/rdoctask'
require 'spec/rake/spectask'


HOME    = File.expand_path(File.dirname(__FILE__))
LIBDIR  = File.join(HOME, 'lib')
DOCDIR  = File.join(HOME, 'docs')
FILES   = FileList["#{LIBDIR}/**/*.rb"]         # for yard, but where to put them?

def dev_host
  case Socket.gethostname
  when /romeo-foxtrot/i ; true
  else ; false
  end
end

Spec::Rake::SpecTask.new do |task|
  task.spec_opts = [ '--format', 'specdoc' ]
  task.libs << 'lib'
  task.libs << 'spec'
  task.rcov = true if dev_host   # do coverage tests on my devlopment box
end


desc "Generate documentation from libraries with yard."
task :docs do

  command = "yardoc --quiet --private --protected --title 'datyl: daitss utilities' --output-dir #{DOCDIR} #{FILES}"
  
  yardoc  = `which yardoc 2> /dev/null`

  if yardoc.empty?
    puts "yard not found, skipping the 'docs' task."
  else
    FileUtils.rm_rf FileList["#{DOCDIR}/**/*"]
    puts "Creating docs with '#{command}'."
    `#{command}`
  end
end

desc "Make emacs tags files"
task :etags do
  files = (FileList['lib/**/*', "tools/**/*", 'views/**/*', 'spec/**/*', 'bin/**/*']).exclude('spec/files', 'spec/reports')        # run yard/hanna/rdoc on these and..
  sh "xctags -e #{files}"
end

defaults = [:spec]
defaults.push :etags   if dev_host

task :default => defaults
