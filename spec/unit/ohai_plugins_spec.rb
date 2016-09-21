require 'spec_helper'
require 'fileutils'

describe Cupper::OhaiPlugin do

  let(:test_path) do
    File.expand_path(File.dirname __FILE__) + '/project_test'
  end

  let(:ohai_plugin) do
    Cupper::OhaiPlugin.new
  end

  before(:each) do
    Dir.mkdir(test_path) if not Dir.exist?(test_path)
  end

  after(:each) do
    FileUtils.rm_rf(test_path) if Dir.exist?(test_path)
  end

  it 'should return a list of plugins from ohai' do
    allow(File).to receive(:expand_path).and_return(test_path)
    File.new(test_path + '/plugin1.rb','w')
    File.new(test_path + '/plugin2.rb','w')
    File.new(test_path + '/plugin3.rb','w')
    expect(ohai_plugin.list).to eq(['plugin1','plugin2','plugin3']) # TODO: the list is returning out of order in some case
  end
end
