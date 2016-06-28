describe PagedMedia::ObjectBehavior do
  let(:collection_with_chapters) { FactoryGirl.create :collection, :with_chapters }
  class StubObject
    include PagedMedia::ObjectBehavior
    attr_accessor :ordered_members, :member_of, :title, :id
    def initialize(**opts)
      @ordered_members = opts[:ordered_members] || []
      @member_of = opts[:member_of] || []
      @title = opts[:title] || 'title'
      @id = opts[:id] || 'id'
    end
  end
  let(:so0) { StubObject.new(title: 'title0', id: 'id0') }
  let(:so1) { StubObject.new(title: 'title1', id: 'id1') }
  let(:so2) { StubObject.new(title: 'title2', id: 'id2') }
  let(:so3) { StubObject.new(title: 'title3', id: 'id3') }
  before(:each) do
    so0.ordered_members = [so1, so3]
    so1.member_of = [so0]
    so3.member_of = [so0]
    so1.ordered_members = [so2]
    so2.member_of = [so1]
  end
  after(:all) do
    Collection.destroy_all
  end
  let(:test_ancestor) { so0 }
  let(:children) { test_ancestor.ordered_members.to_a }
  let(:children_and_grandchildren) do
    results = children
    children.each do |member|
      results += member.ordered_members.to_a
    end
    results
  end
  let(:test_descendent) { so2 }
  let(:parents) { test_descendent.member_of.to_a }
  let(:parents_and_grandparents) do
    results = parents
    parents.each do |parent|
      results += parent.member_of.to_a
    end
    results
  end

  describe '#descendents_tree' do
    let(:descendents_tree) { test_ancestor.descendents_tree }
    it 'returns a recursive Hash of child objects' do
      expect(descendents_tree).to be_a Hash
      children.each do |child|
        expect(descendents_tree.keys).to include child
        expect(descendents_tree[child]).to be_a Hash
        if child.ordered_members.to_a.empty?
          expect(descendents_tree[child]).to be_empty
        else
          child.ordered_members.to_a.each do |grandchild|
            expect(descendents_tree[child].keys).to include grandchild
          end
        end
      end
    end
  end

  describe '#descendents_tree_ids' do
    let(:descendents_tree_ids) { test_ancestor.descendents_tree_ids }
    it 'returns a recursive Hash of child ids' do
      expect(descendents_tree_ids).to be_a Hash
      children.each do |child|
        expect(descendents_tree_ids.keys).to include child.id
        expect(descendents_tree_ids[child.id]).to be_a Hash
        if child.ordered_members.to_a.empty?
          expect(descendents_tree_ids[child.id]).to be_empty
        else
          child.ordered_members.to_a.each do |grandchild|
            expect(descendents_tree_ids[child.id].keys).to include grandchild.id
          end
        end
      end
    end
  end

  describe '#descendents_list' do
    let(:descendents_list) { test_ancestor.descendents_list }
    it 'returns an Array of descendent objects' do
      expect(descendents_list).to be_a Array
      children_and_grandchildren.each do |descendent|
        expect(descendents_list).to include descendent
      end
    end
  end

  describe '#descendents_list_ids' do
    let(:descendents_list_ids) { test_ancestor.descendents_list_ids }
    it 'returns an Array of descendent ids' do
      expect(descendents_list_ids).to be_a Array
      children_and_grandchildren.each do |descendent|
        expect(descendents_list_ids).to include descendent.id
      end
    end
  end

  describe '#descendents_list_titles' do
    let(:descendents_list_titles) { test_ancestor.descendents_list_titles }
    it 'returns an Array of descendent titles' do
      expect(descendents_list_titles).to be_a Array
      children_and_grandchildren.each do |descendent|
        expect(descendents_list_titles).to include descendent.title
      end
    end
  end

  describe '#ancestors_tree' do
    let(:ancestors_tree) { test_descendent.ancestors_tree }
    it 'returns a recursive Hash of parent objects' do
      expect(ancestors_tree).to be_a Hash
      parents.each do |parent|
        expect(ancestors_tree.keys).to include parent
        expect(ancestors_tree[parent]).to be_a Hash
        if parent.member_of.to_a.empty?
          expect(ancestors_tree[parent]).to be_empty
        else
          parent.member_of.to_a.each do |grandparent|
            expect(ancestors_tree[parent].keys).to include grandparent
          end
        end
      end
    end
  end

  describe '#ancestors_tree_ids' do
    let(:ancestors_tree_ids) { test_descendent.ancestors_tree_ids }
    it 'returns a recursive Hash of parent ids' do
      expect(ancestors_tree_ids).to be_a Hash
      parents.each do |parent|
        expect(ancestors_tree_ids.keys).to include parent.id
        expect(ancestors_tree_ids[parent.id]).to be_a Hash
        if parent.member_of.to_a.empty?
          expect(ancestors_tree[parent.id]).to be_empty
        else
          parent.member_of.to_a.each do |grandparent|
            expect(ancestors_tree_ids[parent.id].keys).to include grandparent.id
          end
        end
      end
    end
  end

  describe '#ancestors_list' do
    let(:ancestors_list) { test_descendent.ancestors_list }
    it 'returns an Array of ancestor objects' do
      expect(ancestors_list).to be_a Array
      parents_and_grandparents.each do |ancestor|
        expect(ancestors_list).to include ancestor
      end
    end
  end

  describe '#ancestors_list_ids' do
    let(:ancestors_list_ids) { test_descendent.ancestors_list_ids }
    it 'returns an Array of ancestor objects' do
      expect(ancestors_list_ids).to be_a Array
      parents_and_grandparents.each do |ancestor|
        expect(ancestors_list_ids).to include ancestor.id
      end
    end
  end

  describe "#cont_array" do
    it 'returns an Array of id/title/type hashes for descendent containers' do
      cont_array = collection_with_chapters.cont_array
      containers_list = collection_with_chapters.descendents_list(Container)
      expect(containers_list).not_to be_empty
      containers_list.each_with_index do |container, index|
        expect(cont_array[index]['id']).to eq container.id
        expect(cont_array[index]['title']).to eq container.title
        expect(cont_array[index]['type']).to eq container.class.to_s
      end
    end
  end

end
