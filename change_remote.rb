OLD_USERNAME = 'emmasax1'
NEW_USERNAME = 'emma-sax4'

current_dir = Dir.pwd
nested_dirs = Dir.entries(current_dir).select do |entry|
  entry_dir = File.join(current_dir, entry)
  File.directory?(entry_dir) && !(entry == '.' || entry == '..')
end

nested_dirs.each do |dir|
  Dir.chdir dir
  if File.exist?('.git')
    puts "Found git directory: #{dir}."
    resp = `git remote -v`
    if resp.include?(OLD_USERNAME)
      puts "  Git directory's remote is pointing to: '#{OLD_USERNAME}'.'"
      repo = resp.scan(/\/([\S]*).git/).first.first.sub(OLD_USERNAME, NEW_USERNAME)
      remote_name = resp.scan(/([a-zA-z]+)/).first.first
      puts "  Changing the remote URL #{remote_name} to be git@github.com:#{NEW_USERNAME}/#{repo}."
      begin
        `git remote set-url #{remote_name} git@github.com:#{NEW_USERNAME}/#{repo}`
        puts "  Done."
      rescue Exception => e
        puts "  Could not complete: #{e.message}"
      end
    else
      puts "  No need to update this directory's remote URL."
    end
  end
  Dir.chdir current_dir
end
