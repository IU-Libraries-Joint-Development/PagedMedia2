require 'generators/paged_media/work/work_generator'

describe PagedMedia::WorkGenerator, :type => :generator do
  destination File.expand_path("../../../tmp/test", __FILE__)
  before do
    prepare_destination
    FileUtils.mkdir_p file('config/initializers')
    FileUtils.copy_file(Rails.root + 'config/initializers/curation_concerns.rb',
      file('config/initializers/curation_concerns.rb'))
  end
  
    describe 'generated files' do
      let (:files) { 
        {controller:'app/controllers/curation_concerns/new_types_controller.rb',
         view: 'app/views/curation_concerns/new_types/_new_type.html.erb',
         actor: 'app/actors/curation_concerns/new_type_actor.rb',
         model: 'app/models/new_type.rb',
         controller_spec: 'spec/controllers/curation_concerns/new_types_controller_spec.rb',
         actor_spec: 'spec/actors/curation_concerns/new_type_actor_spec.rb',
         model_spec: 'spec/models/new_type_spec.rb',
         config: 'config/initializers/curation_concerns.rb'
        }
      }

      before do
        run_generator %w(NewType)
      end

      describe 'has a model' do
        subject { file(files[:model]) }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has a controller' do
        subject { file(files[:controller]) }
        it { is_expected.to exist }
        it { is_expected.to contain /NewTypesController/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has an actor' do
        subject { file(files[:actor]) }
        it { is_expected.to exist }
        it { is_expected.to contain /class NewTypeActor/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has views' do
        subject { file(files[:view]) }
        it { is_expected.to exist }
        #it { is_expected.to contain /class NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has model specs' do
        subject { file(files[:model_spec]) }
        it { is_expected.to exist }
        it { is_expected.to contain /describe NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has controller specs' do
        subject { file(files[:controller_spec]) }
        it { is_expected.to exist }
        it { is_expected.to contain /describe CurationConcerns::NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has actor specs' do
        subject { file(files[:actor_spec]) }
        it { is_expected.to exist }
        it { is_expected.to contain /describe CurationConcerns::NewType/ }
        it { is_expected.to have_correct_syntax }
      end
      describe 'is a registered concern' do
        subject { file(files[:config]) }
        it { is_expected.to exist }
        it { is_expected.to contain 'CurationConcerns.configure do |config|' }
        it { is_expected.to contain 'config.register_curation_concern :new_type' }
        it { is_expected.to have_correct_syntax }
      end
      describe 'has metadata methods matching the configuration'
    end
end
