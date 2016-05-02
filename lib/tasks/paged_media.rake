require 'rspec/core'
require 'rspec/core/rake_task'

# require 'jettywrapper'
# JETTY_ZIP_BASENAME = 'master'
# Jettywrapper.url = "https://github.com/projecthydra/hydra-jetty/archive/#{JETTY_ZIP_BASENAME}.zip"

desc 'Run specs on travis'
task :ci do
  ENV['RAILS_ENV'] = 'test'
  ENV['TRAVIS'] = '1'
  # TODO We need the solr_wrapper and fcrepo_wrapper startup to go here instead of jetty
  #jetty_params = Jettywrapper.load_config
  #error = Jettywrapper.wrap(jetty_params) do
    #Rake::Task['spec'].invoke
  #end
  #raise "test failures: #{error}" if error

  FcrepoWrapper.wrap(port: 8986, enable_jms: false) do |fc|
    SolrWrapper.wrap(port: 8985, verbose: true) do |solr|
      solr.with_collection name: 'test', dir: File.join(Rails.root, 'solr', 'config') do
        Rake::Task['spec'].invoke
      end
    end
  end
end
