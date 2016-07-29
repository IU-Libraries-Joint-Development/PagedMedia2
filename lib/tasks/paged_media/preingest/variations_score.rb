module PagedMedia
  module PreIngest
    module VariationsScore
      def VariationsScore.preingest(dir)
        Dir.glob(dir + '/*').select { |f| File.directory?(f) }.each do |subdir|
          puts "Looking in: #{subdir}"
          xml_files = Dir.glob(subdir + "/" + "*.xml").select { |f| File.file?(f) }
          puts "XML files found: #{xml_files.inspect}"
          xml_files.each do |xml_file|
            puts "XML file: #{xml_file}"
            xml_content = File.open(xml_file).read
            xml = Nokogiri::XML(xml_content)
            VariationsScore.preingest_file(xml_file, xml)
          end
        end
      end
      def VariationsScore.structure_to_array(basename, xml_node)
        array = []
        xml_node.xpath('child::*').each do |child|
          c = {}
          if child.name == 'Div'
            c['container'] = {}
            c['container']['visibility'] = 'open'
            c['container']['title'] = child['label']
            c['container']['ordered_members'] = VariationsScore.structure_to_array(basename, child)
            array << c
          elsif child.name == 'Chunk'
            c['file_set'] = {}
            c['file_set']['visibility'] = 'open'
            c['file_set']['title'] = [child['label']]
            #FIXME: stub filename logic, limited to 4
            file_num = child.xpath('.//ContentInterval').first['end'].to_i
            file_num = 0 if file_num > 4
            c['file_set']['file'] = "#{basename}-1-#{file_num}.png" unless file_num.zero?
            array << c
          end
        end
        array
      end
      def VariationsScore.preingest_file(filename, xml)
        # set up output
        yaml = {}
        basename = Pathname.new(filename).basename.to_s.gsub('.xml', '')

        # stub in test output
        yaml['musical_score'] = {}
        yaml['musical_score']['title'] = ['TITLE MISSING']
        yaml['musical_score']['creator'] = ['AUTHOR MISSING']
        yaml['musical_score']['visibility'] = 'open'
        yaml['musical_score']['ordered_members'] = []

        # parse real output
        yaml['musical_score']['title'] = xml.xpath('/ScoreAccessPage/RecordSet/Container/DisplayTitle').map(&:content)
        yaml['musical_score']['creator'] = xml.xpath('/ScoreAccessPage/Bibinfo/Author').map(&:content)
        structure = xml.xpath('/ScoreAccessPage/RecordSet/Container/Structure/Item').first
        s = VariationsScore.structure_to_array(basename, structure)
        yaml['musical_score']['ordered_members'] = s

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
