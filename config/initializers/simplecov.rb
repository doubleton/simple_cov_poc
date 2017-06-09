module SimpleCov
  module ResultMerger
    class << self
      DEFAULT_REDIS_KEY = 'default_test_cov'

      def redis_key
        ENV.fetch('TEST_COV') { DEFAULT_REDIS_KEY }
      end

      # Returns the contents of the resultset cache as a string or if the file is missing or empty nil
      def stored_data
        Redis.current.get(redis_key)
      end

      # Saves the given SimpleCov::Result in the resultset cache
      def store_result(result)
        new_set = resultset
        command_name, data = result.to_hash.first
        new_set[command_name] = data
        Redis.current.set(redis_key, JSON.pretty_generate(new_set))

        true
      end
    end
  end

  module Formatter
    class HTMLFormatter

      private

      def asset_output_path
        return @asset_output_path if defined?(@asset_output_path) && @asset_output_path
        @asset_output_path = File.join(asset_root_path, 'assets', SimpleCov::Formatter::HTMLFormatter::VERSION)
        FileUtils.mkdir_p(@asset_output_path)
        @asset_output_path
      end

      def asset_root_path
        @asset_root_path ||= Rails.root.join('public').to_s
      end
    end
  end
end