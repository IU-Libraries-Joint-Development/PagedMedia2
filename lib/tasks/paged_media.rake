require 'rspec/core'
require 'rspec/core/rake_task'
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
    FcrepoWrapper.wrap(port: 8984, enable_jms: false) do |fc|
      SolrWrapper.wrap(port: 8983, verbose: true) do |solr|
        solr.with_collection name: 'hydra-development', dir: File.join(Rails.root, 'solr', 'config') do
          sh('rails s')
        end
      end
    end
  end

  desc 'Run ingest'
  task :ingest => :environment do
    PagedMedia::Ingest::Tasks.ingest
  end

end
