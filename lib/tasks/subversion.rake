namespace :svn do
  desc 'Update to latest revision and update revion and history files.'
  task(:update) {
    puts 'updating project...'
    system 'svn update'
    puts 'generating log history...'
    system 'svn log -v > public/history.txt'
    puts 'outputting revision information...'
    revision = `svn info | grep Revision`
    revision.gsub!(/\n+/, '')
    revision_date = `svn info | grep "Last Changed Date" | awk '{print $4, $5}'`
    revision_date.gsub!(/\n+/, '')
    File.open('public/revision', 'w') {|f| f.write(revision + " / " + revision_date) }
    puts "done!"
  }
end