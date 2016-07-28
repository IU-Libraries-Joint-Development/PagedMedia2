require 'rspec/core'
require 'rspec/core/rake_task'
require 'optparse'
require './lib/tasks/paged_media/preingest'
require './lib/tasks/paged_media/ingest'

namespace :paged_media do
  # Pass arguments to rspec via ENV variables
  # Examples:
  #   rake paged_media:spec RSPEC_OPTS='-f d' # documentation output format
  #   rake paged_media:spec RSPEC_PATTERN=spec/models/* \
  #     RSPEC_EXCLUDE_PATTERN=spec/models/container.rb # run model specs, except container
  desc 'Paged Media rspec task'
  RSpec::Core::RakeTask.new(:rspec) do |task|
    task.rspec_opts      = ENV['RSPEC_OPTS']            if ENV['RSPEC_OPTS'].present?
    task.pattern         = ENV['RSPEC_PATTERN']         if ENV['RSPEC_PATTERN'].present?
    task.exclude_pattern = ENV['RSPEC_EXCLUDE_PATTERN'] if ENV['RSPEC_EXCLUDE_PATTERN'].present?
  end

  desc 'Run Paged Media spec tests'
  task :spec do
    FcrepoWrapper.wrap(port: 8986, enable_jms: false) do |fc|
      SolrWrapper.wrap(port: 8985, verbose: true) do |solr|
        solr.with_collection name: 'hydra-test', dir: File.join(Rails.root, 'solr', 'config') do
          Rake::Task['paged_media:rspec'].invoke
        end
      end
    end
  end

  desc 'Run pre-ingest'
  task :preingest => :environment do
    PagedMedia::PreIngest::Tasks.preingest
  end

  desc 'Run console (in wrappers)'
  task :console do
    FcrepoWrapper.wrap(port: 8984, enable_jms: false) do |fc|
      SolrWrapper.wrap(port: 8983, verbose: true) do |solr|
        solr.with_collection name: 'hydra-development', dir: File.join(Rails.root, 'solr', 'config') do
          sh('rails c')
        end
      end
    end
  end

  desc 'Run server (in wrappers)'
  task :server do
    # Default development values
    options = {
      fc_port: 8984,
      solr_port: 8983,
      col_name: 'hydra-development',
      server_env: ''
    }
    o = OptionParser.new
    o.banner = "Usage: rake paged_media:server [options]"
    o.on("-e ENV", "--environment ENV") do |env|
      # Set values for test server
      if env.eql?('test') then
        options[:fc_port] = 8986
        options[:solr_port] = 8985
        options[:col_name] = 'hydra-test'
        options[:server_env] = '-e test'
      end
    end
    # return `ARGV` with the intended arguments
    args = o.order!(ARGV) {}
    o.parse!(args)

    FcrepoWrapper.wrap(port: options[:fc_port], enable_jms: false) do |fc|
      SolrWrapper.wrap(port: options[:solr_port], verbose: true) do |solr|
        solr.with_collection name: options[:col_name], dir: File.join(Rails.root, 'solr', 'config') do
          sh("rails s #{options[:server_env]}")
        end
      end
    end
  end

  desc 'Run ingest'
  task :ingest => :environment do
    PagedMedia::Ingest::Tasks.ingest
  end

end
