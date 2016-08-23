require 'spec_helper'
require 'fileutils'

describe Cupper::Project do
  let(:test_path) do
    File.expand_path(File.dirname __FILE__) + "/project_test"
  end

  let(:project) do
    Cupper::Project.new('BETA', test_path)
  end

  before(:each) do
    Dir.mkdir(test_path) if not Dir.exist?(test_path)
  end

  after(:each) do
    FileUtils.rm_rf(test_path) if Dir.exist?(test_path)
  end

  it 'should generate the root project dir' do
    project.create
    created = Dir.exist?(project.dir)
    expect(created).to be_truthy
  end

  it 'should create a project with a CupperFile' do
    project.create
    created = File.exist?("#{ project.dir }/#{ project.name }/CupperFile")
    expect(created).to be_truthy
  end

  it 'should create a cookbooks subdir' do
    project.create
    created = Dir.exist?("#{ project.dir }/#{ project.name }/cookbooks")
    expect(created).to be_truthy
  end

  it 'should not create a project when there is already one'
end
