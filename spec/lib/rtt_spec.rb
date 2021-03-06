require File.expand_path(File.join( File.dirname(__FILE__), '..', 'ar_spec_helper'))

describe Rtt do

  before do
    setup_testing_env
  end

  describe '#set_project' do

    it 'should set the project as current at system-level' do
      Rtt.set_project 'project_name'
      Project.where(:active => true).first.name.should == 'project_name'
    end

  end

  describe '#set_client' do

    it 'should set the client as current at system-level' do
      Rtt.set_client 'client_name'
      Client.where(:active => true).first.name.should == 'client_name'
    end

  end

  describe '#rename' do

    describe 'when there is no current task' do

      it 'should not create a task' do
        Rtt.start 'development_task'
        Task.all.length == 0
      end
    end
  end

  describe '#start' do

    describe 'when there is no current task' do

      it 'should start a task for the name given' do
        Rtt.start 'development_task'
        task = Task.where(:name => 'development_task').first
        task.should_not be_nil
      end

    end

    describe 'when there is a current task' do

      before do
        @current_task = Task.create :name => 'older_task', :start_at => Date.today.beginning_of_day, :active => true, :rate => 100
      end

      it 'should create a new task' do
        task = Rtt.start 'development_task'
        Task.all.length.should == 2
      end

      it 'should change end_at of older_task' do
        @end_at = @current_task.end_at
        Rtt.start 'development_task'
        Task.where(:name => 'development_task').first.end_at.should == @end_at
      end

      it 'should change set active to false of older_task' do
        Rtt.start 'development_task'
        Task.where(:name => 'development_task').first.active.should be_true
      end

      describe 'task name is passed' do

        it 'should use name and desciption if present' do
          task = Rtt.start 'development_task'
          task.name.should == 'development_task'
        end
      end

      describe 'task name is absent' do

        it 'should use use the existing active task' do
          task = Rtt.start
          task.name.should == 'older_task'
        end
      end
    end

    describe 'with default active project and client' do

      it 'should reference the default client' do
        task = Rtt.start 'development_task'
        task.client.name.should == Client::DEFAULT_NAME
      end

      it 'should reference the default project' do
        task = Rtt.start 'development_task'
        task.project.name.should == Project::DEFAULT_NAME
      end
    end

    describe 'with custom active project and client' do

      before do
        @client = Rtt.set_client 'custom_client'
        @project = Rtt.set_project 'custom_project'
      end

    end
  end

  describe '#stop' do

    describe 'when there is a current task' do

      before do
        Task.create :name => 'older_task', :start_at => Date.today.beginning_of_day, :active => true, :rate => 100
      end

      it 'should finish the task' do
        Rtt.stop
        Task.where(:name => 'older_task').first.active.should be_false
      end
    end

    describe 'when there is no current task' do

      it 'should not raise an exception' do
        lambda {
          Rtt.stop
        }.should_not raise_error
      end

      it 'should keep the same number of Tasks' do
        Rtt.stop
        Task.all.length.should be_zero
      end
    end
  end

  describe '#rename' do

    describe 'When there is a current task' do

      before do
        @current_task = Task.create :name => 'older_task', :start_at => Date.today.beginning_of_day, :active => true, :rate => 100
      end

      it 'should change the name' do
        @id = @current_task.id
        Rtt.rename 'newer_task'
        Task.find(@id).name.should == 'newer_task'
      end

      it 'should keep the number of tasks' do
        counter = Task.all.length
        Rtt.rename 'newer_task'
        Task.all.length.should == counter
      end
    end

    describe 'When there is NO current task' do

      it 'should not create a new task' do
        Rtt.rename 'newer_task'
        Task.all.length.should be_zero
      end
    end
  end

  describe '#report' do

    it 'should call report_for_csv when :pdf is recevied' do
      Rtt.should_receive(:report_to_pdf).with('/somepath.pdf')
      Rtt.report :pdf => '/somepath.pdf'
    end

    it 'should call report_for_csv when :csv is recevied' do
      pending
      Rtt.should_receive(:report_to_csv).with('/somepath_csv')
      Rtt.report :csv => '/somepath_csv'
    end
  end
end
