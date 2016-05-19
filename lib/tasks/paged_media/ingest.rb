require 'pp'
module PagedMedia
  module Ingest
    module Tasks
      def Tasks.ingest
        puts "Ingest folders found: #{Helpers.ingest_folders.inspect}"
        Helpers::ingest_folders.each do |subdir|
          puts "Running ingest for subfolder: #{subdir}"
          manifest_files = Dir.glob(subdir + "/" + "manifest*.yml").select { |f| File.file?(f) }
          puts "Manifest files found: #{manifest_files.inspect}"
          manifest_files.each do |manifest_file|
            puts "Manifest file: #{manifest_file}"
            manifest = YAML.load_file(manifest_file)
            objects = Helpers.objects_from_hash(manifest)
            objects.each do |object|
              puts "#{object.class}: #{object.title.inspect}"
              pp object.relationship_tree(:members, :title, [])
            end
          end
        end
      end
    end
    module Helpers
      def Helpers.ingest_folders
        ingest_root = "spec/fixtures/ingest/paged_media/"
        return Dir.glob(ingest_root + "*").select { |f| File.directory?(f) }
      end
      def Helpers.objects_from_hash(objects_hash)
        objects_hash.inject([]) do |results_array, (object_class, attributes)|
          object = object_class.to_s.classify.constantize.new
          attributes.each do |att, val|
            case att
            when 'ordered_members'
              val.each do |member_hash|
                Helpers.objects_from_hash(member_hash).each do |member|
                  object.ordered_members << member
                end
              end
            else
              object.send("#{att}=", val)
            end
          end
          object.save!
          results_array << object
        end
      end
    end
  end
end
