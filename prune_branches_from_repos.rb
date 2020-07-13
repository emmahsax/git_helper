# Before running this script, change the following two variables:
#   primary_directory: directory that contains your repositories
#   prune_script: directory that contains the prune script
primary_directory = '/Users/your_user/directory'
prune_script = '/Users/your_user/directory/scripts/prune-merged-branches'

Dir.chdir(primary_directory)
directories = Dir.glob('*').select { |f| File.directory?(f) }
ignored = []

directories.each do |dir|
  Dir.chdir(dir)
  if File.directory?('.git')
    puts "#{dir} is a GitHub repository. Pruning merged branches:"
    system(prune_script)
  else
    puts "#{dir} is not a GitHub repository. Ignoring."
    ignored << dir
  end
  puts "\n\n"
  Dir.chdir(primary_directory)
end

puts "We ignored these directories:\n#{ignored}"

