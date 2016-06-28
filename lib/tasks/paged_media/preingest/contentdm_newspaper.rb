# Preingest for contentDM newspapers
module PagedMedia
  module PreIngest
    module ContentdmNewspaper
      # Find all files that are ready for preingest
      #
      # @param [Dir] dir to search in
      # @return [Files] preingest files
      def ContentdmNewspaper.preingest(dir)
        Dir.glob(dir + '/*').select { |f| File.directory?(f) }.each do |subdir|
          puts "Looking in: #{subdir}"
          xml_files = Dir.glob(subdir + "/" + "*.xml").select { |f| File.file?(f) }
          puts "XML files found: #{xml_files.inspect}"
          xml_files.each do |xml_file|
            puts "XML file: #{xml_file}"
            xml_content = File.open(xml_file).read
            xml = Nokogiri::XML(xml_content)
            self.preingest_file(xml_file, xml)
          end
        end
      end
      # Create a single issue/newpaper array to be added to collection
      #
      # @param [XML_Object] record xml node to parse
      # @return [Hash] issue to be added
      def ContentdmNewspaper.add_newspaper(record)
        issue = {}
        issue['newspaper'] = {}
        issue['newspaper']['title'] = record.xpath('title').map(&:content)
        issue['newspaper']['visibility'] = 'open'
        issue['newspaper']['creator'] = record.xpath('publisher').map(&:content)
        pages = self.add_pages(record.xpath('structure'))
        issue['newspaper']['ordered_members'] = pages
        return issue
      end
      # Create pages array to be added to issue/newspaper
      #
      # @param [XML_Object] pages_xml to parse
      # @return [Array] of pages to add to issue/newspaper
      def ContentdmNewspaper.add_pages(pages_xml)
        pages = []
        pages_xml.xpath('page').each do |page_xml|
          page = {}
          page['file_set'] = {}
          page['file_set']['title'] = page_xml.xpath('pagetitle').map(&:content)
          page['file_set']['visibility'] = 'open'
          pages << page
        end
        return pages
      end
      # Create array of files to add to page
      #
      # @param [XML_Object] page_xml node to parse
      # @return [Array] of files to add to page
      def ContentdmNewspaper.add_files(page_xml)
        # TODO - Will add URL to pull in files (page image, thumbnail, extracted text)
        files[] = []
        page_xml.xpath('pagefile').each do |pagefile_xml|

        end
        return files
      end
      # Create manifext file from preingested data
      # for contentDM newspapers export
      #
      # @param [String] filename of export file which will also be used for collection name
      # @param [File] xml from contentDM export
      # @return [File] description of returned object
      def ContentdmNewspaper.preingest_file(filename, xml)
        # set up output
        yaml = {}
        basename = Pathname.new(filename).basename.to_s.gsub('.xml', '')
        collectionname = basename.gsub('_', ' ')

        # create collection
        yaml['collection'] = {}
        yaml['collection']['title'] = [collectionname]
        yaml['collection']['visibility'] = 'open'

        # parse each record as an issue
        issues = []
        xml.xpath('/metadata/record').each do |record|
          issues << self.add_newspaper(record)
        end

        # add issues to collection
        yaml['collection']['ordered_members'] = issues

        # save output
        output_dir = "spec/fixtures/ingest/#{basename}"
        FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)
        yaml_file = "#{output_dir}/manifest_#{basename}.yml"
        puts "OUTPUT: #{yaml_file}"
        File.open(yaml_file, 'w') { |f| f.write yaml.to_yaml }
      end
    end
  end
end
