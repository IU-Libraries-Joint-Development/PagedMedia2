require 'rspec/core'
require 'rspec/core/rake_task'
require './lib/tasks/paged_media/ingest'

namespace :paged_media do
  desc 'Paged Media rspec task'
  RSpec::Core::RakeTask.new(:rspec)

  desc 'Run Paged Media spec tests'
  task :spec do
    FcrepoWrapper.wrap(port: 8986, enable_jms: false) do |fc|
      SolrWrapper.wrap(port: 8985, verbose: true) do |solr|
        solr.with_collection name: 'test', dir: File.join(Rails.root, 'solr', 'config') do
          Rake::Task['paged_media:rspec'].invoke
        end
      end
    end
  end

  desc 'Run ingest'
  task :ingest => :environment do
    PagedMedia::Ingest::Tasks.ingest
  end

end
