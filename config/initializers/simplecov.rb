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
        results = []
        list = Redis.current.lrange(key, 0, -1)
        list.each do |string|
          result = SimpleCov::Result.from_hash(JSON.parse(string))
          results << result
        end
        results
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

      def format(result)
        Dir[File.join(File.dirname(__FILE__), "../public/*")].each do |path|
          FileUtils.cp_r(path, asset_output_path)
        end

        template("layout").result(binding)

        # File.open(File.join(output_path, "index.html"), "wb") do |file|
        #   file.puts template("layout").result(binding)
        # end
        # index_html
      end

      private

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