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
      # @param [String] fulltext_content_dir directory to story full text
      # @return [Hash] issue to be added
      def ContentdmNewspaper.add_newspaper(record, fulltext_content_dir)
        title = record.xpath('title').map(&:content).first.to_s
        newspaper_content_dir = "#{fulltext_content_dir}/#{title}"
        FileUtils.mkdir_p(newspaper_content_dir) unless File.exists?(newspaper_content_dir)
        issue = {}
        issue['newspaper'] = {}
        issue['newspaper']['title'] = [title]
        issue['newspaper']['visibility'] = 'open'
        issue['newspaper']['creator'] = record.xpath('publisher').map(&:content)
        pages = self.add_pages(record.xpath('structure'), newspaper_content_dir)
        issue['newspaper']['ordered_members'] = pages
        return issue
      end
      # Create pages array to be added to issue/newspaper
      #
      # @param [XML_Object] for pages to parse
      # @param [String] content_dir directory for full text
      # @return [Array] of pages to add to issue/newspaper
      def ContentdmNewspaper.add_pages(pages_xml, content_dir)
        pages = []
        pages_xml.xpath('page').each do |page_xml|
          title = page_xml.xpath('pagetitle').map(&:content).first.to_s
          page_content_dir = "#{content_dir}/#{title}"
          FileUtils.mkdir_p(page_content_dir) unless File.exists?(page_content_dir)
          page = {}
          page['file_set'] = {}
          page['file_set']['title'] = [title]
          page['file_set']['visibility'] = 'open'
          files = self.add_files(page_xml, page_content_dir)
          page['file_set']['files'] = files
          pages << page
        end
        return pages
      end
      # Create array of files to add to page
      #
      # @param [XML_Object] page_xml page node to parse
      # @param [String] content_dir directory for full text
      # @return [Array] of files to add to page
      def ContentdmNewspaper.add_files(page_xml, content_dir)
        files = []
        page_xml.xpath('pagefile').each do |pagefile_xml|
          pagefile_type = pagefile_xml.xpath('pagefiletype').map(&:content).first.to_s
          # File type should be one of: original, thumbnail, extracted
          file_type = ''
          case pagefile_type
          when 'thumbnail'
            file_type = 'thumbnail'
          when 'access'
            file_type = 'original'
          else
            next
          end
          file = {}
          file['file'] = {}
          file['file']['type'] = file_type
          path = pagefile_xml.xpath('pagefilelocation').map(&:content).first.to_s
          file['file']['path'] = self.fix_path_iupui(path)
          files << file
        end
        # Add extracted text
        extracted_text_file = self.content_fulltext(page_xml, content_dir)
        files << extracted_text_file
        return files
      end
      # Pull out fulltext from export file
      #
      # @param [XML_Object]  page_xml
      # @param [String] content_dir directory for full text
      # @return [Type] description of returned object
      def ContentdmNewspaper.content_fulltext(page_xml, content_dir)
        page_text = page_xml.xpath('pagetext').map(&:content).first.to_s
        full_text_file = "#{content_dir}/fulltext.txt"
        File.open(full_text_file,"w"){|f| f.write(page_text)}
        file = {}
        file['file'] = {}
        file['file']['type'] = "extracted"
        file['file']['path'] = full_text_file
        return file
      end
      # Fix file paths for IUPUI exports
      #
      # @param [String] path given from IUPUI contentDM export
      # @return [String] corrected path using new API port for IUPUI contentDM
      def ContentdmNewspaper.fix_path_iupui(path)
        # IUPUI CDM no longer provides API on port 445
        # The API is now available on port 2012
        # Also needs to replace &amp; with just &
        path = path.sub(/445\/cgi-bin/, '2012/cgi-bin')
        path = path.sub('&amp;', '&')
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

        # create directory if needed
        output_dir = "spec/fixtures/ingest/#{basename}"
        FileUtils.mkdir_p(output_dir) unless File.exists?(output_dir)
        content_dir = "#{output_dir}/content"
        FileUtils.mkdir_p(content_dir) unless File.exists?(content_dir)
        full_text_dir = "#{content_dir}/fulltext"
        FileUtils.mkdir_p(full_text_dir) unless File.exists?(full_text_dir)

        # create collection
        yaml['collection'] = {}
        yaml['collection']['title'] = [collectionname]
        yaml['collection']['visibility'] = 'open'

        # parse each record as an issue
        issues = []
        xml.xpath('/metadata/record').each do |record|
          issues << self.add_newspaper(record, full_text_dir)
        end

        # add issues to collection
        yaml['collection']['ordered_members'] = issues

        # save output YAML
        yaml_file = "#{output_dir}/manifest_#{basename}.yml"
        puts "OUTPUT: #{yaml_file}"
        File.open(yaml_file, 'w') { |f| f.write yaml.to_yaml }
      end
    end
  end
end
