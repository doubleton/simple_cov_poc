module SimpleCov

  class << self
    def result
      @result ||= begin
        res = nil

        if running && !result?
          res = SimpleCov::Result.new add_not_loaded_files(Coverage.result)
        end

        if use_merging
          SimpleCov::ResultMerger.store_result(res) if res

          SimpleCov::ResultMerger.merged_result
        else
          res
        end
      end
    ensure
      self.running = false
    end
  end

  module ResultMerger
    class << self
      DEFAULT_REDIS_KEY = 'default_test_cov'

      def redis_key
        ENV.fetch('TEST_COV') { DEFAULT_REDIS_KEY }
      end

      # Returns the contents of the resultset cache as a string or if the file is missing or empty nil
      # def stored_data
      #   Redis.current.get(redis_key)
      # end

      def results(key = redis_key)
        Redis.current.lrange(key, 0, -1).map { |string| SimpleCov::Result.from_hash(JSON.parse(string)) }
      end

      # Saves the given SimpleCov::Result to Redis list
      def store_result(result)
        Redis.current.rpush(redis_key, JSON.pretty_generate(result.to_hash))
        true
      end
    end
  end

  module Formatter
    class HTMLFormatter

      attr_reader :lines_by_file

      def initialize
        if ENV['DIFF_FILE_PATH']
          @lines_by_file = GitDiffParser.parse(File.read(ENV['DIFF_FILE_PATH'])).map do |patch|
            [patch.file, patch.changed_line_numbers]
          end.to_h
        end
      end

      def format(result)
        Dir[File.join(File.dirname(__FILE__), "../public/*")].each do |path|
          FileUtils.cp_r(path, asset_output_path)
        end

        template('layout').result(binding)

        # File.open(File.join(output_path, "index.html"), "wb") do |file|
        #   file.puts template("layout").result(binding)
        # end
        # index_html
      end

      private

      def custom_template(name)
        ERB.new(File.read(Rails.root.join('lib/simplecov-html/views/', "#{name}.erb")))
      end

      # Returns a table containing the given source files
      def formatted_file_list(title, source_files)
        title_id = title.gsub(/^[^a-zA-Z]+/, "").gsub(/[^a-zA-Z0-9\-\_]/, "")
        # Silence a warning by using the following variable to assign to itself:
        # "warning: possibly useless use of a variable in void context"
        # The variable is used by ERB via binding.
        title_id = title_id
        custom_template("file_list").result(binding)
      end

      def formatted_source_file(source_file)
        custom_template('source_file').result(binding)
      end

      def file_from_pr?(source_file)
        (lines_by_file || {})[shortened_filename(source_file)].present?
      end

      def line_from_pr?(source_file, line_number)
        (lines_by_file || {})[shortened_filename(source_file)]&.include?(line_number)
      end

      def asset_output_path
        return @asset_output_path if defined?(@asset_output_path) && @asset_output_path
        @asset_output_path = File.join(asset_root_path, 'assets', SimpleCov::Formatter::HTMLFormatter::VERSION)
        FileUtils.mkdir_p(@asset_output_path)
        @asset_output_path
      end

      def asset_root_path
        @asset_root_path ||= Rails.root.join('public/testings').to_s
      end
    end
  end
end