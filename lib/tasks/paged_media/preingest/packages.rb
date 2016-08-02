require 'fileutils'

module PagedMedia
  module PreIngest
    module Package
      # Find all YAML file to be copied
      #
      # @param [Type] dir directory to search in
      # @return [Type] preingest files
      def Package.preingest(dir)
        Dir.glob(dir + "/*").select {|f| File.directory?(f)}.each do |subdir|
          puts "Looking in: #{subdir}"
          yml_files = Dir.glob(subdir + "/manifest_" + "*.yml").select { |f| File.file?(f) }
          puts "YAML files found: #{yml_files.inspect}"
          yml_files.each do |yml_file|
            puts "YAML file: #{yml_file}"
            self.preingest_file(yml_file, subdir)
          end
        end
      end
      # Copy file to ingest directory
      #
      # @param [Type] file file to copy
      # @param [Type] subdir directory name to use
      # @return [Type] description of returned object
      def Package.preingest_file(file, subdir)
        dir_basename = Pathname.new(subdir).basename.to_s
        file_basename = Pathname.new(file).basename.to_s
        output_file = "spec/fixtures/ingest/#{dir_basename}/#{file_basename}"
        puts "OUTPUT: #{output_file}"
        FileUtils.cp file, output_file
      end
    end
  end
end
