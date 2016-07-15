require 'spec_helper'
require 'fileutils'

describe Cupper::Project do
  before(:example) do
    @project_name = 'BETA'
    @project = Cupper::Project.new(@project_name)
  end

  # TODO: find a better way to do the generated dirs and files
  after(:example) do
    FileUtils.rm_rf(@project.dir) if Dir.exist?(@project.dir)
  end

  it 'should generate the root project dir' do
    @project.create
    created = Dir.exist?(@project.dir)
    expect(created).to be_truthy
  end

  it 'should create a project with a CupperFile' do
    @project.create
    created = File.exist?("#{@project.dir}/CupperFile")
    expect(created).to be_truthy
  end

  it 'should create a cookbooks subdir' do
    @project.create
    created = Dir.exist?("#{@project.dir}/cookbooks")
    expect(created).to be_truthy
  end

  it 'should not create a project when there is a dir with the same name of the project' do
    Dir.mkdir(@project.dir)
    expect { @project.create }.to output(/^Fail/).to_stdout
  end
end
