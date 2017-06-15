class SimpleCov::GitDiffFilter < SimpleCov::Filter

  attr_reader :diff_files

  def initialize(diff_file_path)
    @diff_files = File.readlines(diff_file_path)
  end

  # def initialize(target_branch, base_branch = 'master')
  #   diff = %x(git diff --name-only #{base_branch}..#{target_branch})
  #   @diff_files = diff.split(/\n/)
  # end

  def matches?(source_file)
    diff_files.none? do |arg|
      source_file.filename =~ /#{arg}/
    end
  end

end