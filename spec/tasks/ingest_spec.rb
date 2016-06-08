require './lib/tasks/paged_media/ingest'

describe PagedMedia::Ingest do
  describe PagedMedia::Ingest::Tasks do
    describe '.ingest' do
      it 'adds 2 PagedWork objects' do
        expect { PagedMedia::Ingest::Tasks.ingest }.to change(PagedWork, :count).by(2)
      end
    end
  end
end
