%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/gepetto'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('gepetto', Gepetto::VERSION) do |p|
  p.developer('Alban Peignier', 'alban.peignier@free.fr')
  p.changes              = p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.rubyforge_name       = p.name # TODO this is default value
  p.extra_deps         = [
     ['rubigen',">= #{RubiGen::VERSION}"],
     ['echoe',">= 3.0.2"],
     ['cucumber',">= 0.1.8"],
     ['hoe',">= 1.8.0"],
     ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  # p.extra_dev_deps = [
  #   ['newgem', ">= #{::Newgem::VERSION}"]
  # ]

  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]
