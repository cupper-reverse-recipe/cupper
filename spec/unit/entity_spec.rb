require 'spec_helper'
require 'fileutils'

describe Cupper::Entity do

  class Extention
    include Cupper::Entity
    def initialize(name, dest_path, erb_file=nil, type=nil, extention='')
      super(name,dest_path,erb_file,type,extention)
    end
  end

  let(:test_path) do
    File.expand_path(File.dirname __FILE__) + '/project_test'
  end

  let(:entity) do
    entity = Extention.new('entity',test_path)
    entity.extend(Cupper::Entity)
  end

  let(:entity_dir) do
    entity = Extention.new('entity',test_path, '', Cupper::Entity::DIR)
    entity.extend(Cupper::Entity)
  end

  let(:fake_erb) do
    File.expand_path(File.dirname __FILE__) + '/project_test/fake.erb'
  end

  let(:fake_erb_content) do
    ''
  end

  before(:each) do
    Dir.mkdir(test_path) if not Dir.exist?(test_path)
    File.open(fake_erb,'w')
  end

  after(:each) do
    FileUtils.rm_rf(test_path) if Dir.exist?(test_path)
  end

  it 'should has full path for the file' do
    expect(entity.full_path).to include test_path
  end

  it 'should return a content of ERB file' do
    stub_const('Cupper::TEMPLATE_PATH', test_path)
    expect(entity.content('fake')).to eq(fake_erb_content)
  end

  it 'should be a file' do
    expect(entity.file?).to be_truthy
    expect(entity.dir?).not_to be_truthy
  end

  it 'should be a dir' do
    expect(entity_dir.dir?).to be_truthy
    expect(entity_dir.file?).not_to be_truthy
  end

  it 'should exist' do
    expect(entity.exist?).to be_truthy
  end

  it 'should not exist' do
    expect(entity.exist?).not_to be_truthy
  end

  it 'should load and save template' do
    stub_const('Cupper::TEMPLATE_PATH', test_path)
    entity.content('fake')
    entity.save
    expect(File.exist?(entity.full_path)).to be_truthy
  end
end
