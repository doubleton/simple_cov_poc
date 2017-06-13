class TestingsController < ApplicationController
  before_action :set_testing, only: [:show, :destroy]

  def index
    @testings = Redis.current.smembers(tests_key)
  end

  def show
    result = SimpleCov::ResultMerger.merge_results(*SimpleCov::ResultMerger.results(@testing))

    render html: result.format!.html_safe, layout: false
  end

  def destroy
    Redis.current.srem(tests_key, @testing)
    redirect_to testings_path, notice: 'Testing was successfully destroyed.'
  end

  # def snapshot
  #   SimpleCov.result.format!
  #   redirect_to testings_path, notice: 'Snapshot was successfully taken.'
  # end

  private

  def tests_key
    ENV.fetch('TESTS_KEY') { 'tests' }
  end

  def set_testing
    @testing = params[:id]
  end

end