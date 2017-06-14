result = %x(git diff --name-status master..branch1)
puts result.split(/\n/).map { |s| s.split(/\t/)[1] }