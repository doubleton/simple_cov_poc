class SimpleCov::GitDiffFilter < SimpleCov::Filter

  attr_reader :diff_files

  def initialize(target_branch, base_branch = 'master')
    diff = %x(git diff --name-status #{base_branch}..#{target_branch})
    @diff_files = diff.split(/\n/).map { |s| s.split(/\t/)[1] }
  end

  def matches?(source_file)
    diff_files.none? do |arg|
      source_file.filename =~ /#{arg}/
    end
  end

end