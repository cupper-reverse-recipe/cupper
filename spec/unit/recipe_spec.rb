require 'spec_helper'
require 'fileutils'

describe Cupper::Recipe do

  let(:test_path) do
    File.expand_path(File.dirname __FILE__) + '/project_test'
  end

  let(:collector) do
    Cupper::Collect.new
  end

  let(:recipe) do
    Cupper::Recipe.new(test_path,collector)
  end

  let(:extracted_packages) do
    [
      ['mapa_do_maroto', { 'version' => '1.2.3' }],
      ['hello_world', { 'version' => '1.2.3' }]
    ]
  end

  let(:extracted_links) do
    [
      ['zelda', {
        'type' => 'symbolic link',
        'group' => 'root',
        'mode' => '700',
        'owner' => 'root'
      }],
      ['hello_world', {
        'type' => 'file',
        'group' => 'root',
        'mode' => '644',
        'owner' => 'root'
      }]
    ]
  end

  before(:each) do
    Dir.mkdir(test_path) if not Dir.exist?(test_path)
  end

  after(:each) do
    FileUtils.rm_rf(test_path) if Dir.exist?(test_path)
  end

  it 'should create the recipe' # Method stub is not working with recipe.create
  it 'should expand packages from the collector extractor' do
    expand = recipe.expand_packages(extracted_packages)
    expand.each do |package|
      expect(package).to be_a(Cupper::Attribute)
    end
  end

  it 'should expand link from the collector extractor' do
    expand = recipe.expand_links(extracted_links)
    expand.each do |link|
      expect(link).to be_a(Cupper::Attribute)
    end
  end

  it 'should check if file is a symbolic link' do
    rt_true = recipe.link_type?([ 'zelda', { 'type' => 'symbolic link' }])
    rt_false = recipe.link_type?([ 'zelda', { 'type' => 'symbolic' }])
    expect(rt_true).to be_truthy
    expect(rt_false).not_to be_truthy
  end

  it 'should converte the notation of mode to the number notation' do
    expect(recipe.convert_mode 'rwxrwxrwx').to eq('777')
    expect(recipe.convert_mode 'rwxr-xr-x').to eq('755')
    expect(recipe.convert_mode 'rwx------').to eq('700')
    expect(recipe.convert_mode 'rw-rw-rw-').to eq('666')
    expect(recipe.convert_mode 'rw-r--r--').to eq('644')
    expect(recipe.convert_mode 'rw-------').to eq('600')
    expect(recipe.convert_mode 'invalid').to eq('Unknown')
  end

  it 'should create a new package using attribute class' do
    new_pkg = recipe.new_package('box','0.0.0')
    expect(new_pkg).to be_a(Cupper::Attribute)
    expect(new_pkg).to have_attributes(:name => 'box', :version => '0.0.0')
  end

  it 'should create a new service using attribute class' do
    new_service = recipe.new_service('nginx', 'install', 'systemd')
    expect(new_service).to be_a(Cupper::Attribute)
    expect(new_service).to have_attributes(:name => 'nginx', :action => 'install', :provider => 'systemd')
  end

  it 'should create a new link using attribute class' do
    new_link = recipe.new_link('root', 'rw-r--r--', 'root', '/etc/config', '/etc/file')
    expect(new_link).to be_a(Cupper::Attribute)
    expect(new_link).to have_attributes(:group => 'root',
                                        :mode  => '644',
                                        :owner => 'root',
                                        :target_file => '/etc/config',
                                        :to => '/etc/file')
  end
end
