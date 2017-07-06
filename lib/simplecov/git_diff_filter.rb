class SimpleCov::GitDiffFilter < SimpleCov::Filter

  attr_reader :diff_files

  def initialize(diff_file_path)
    patches = GitDiffParser.parse(File.read(diff_file_path))
    @diff_files = patches.map(&:file)
  end

  def matches?(source_file)
    diff_files.none? do |arg|
      source_file.filename =~ /#{arg}/
    end
  end

end