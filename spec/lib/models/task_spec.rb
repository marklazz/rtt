require 'mocha'
require File.expand_path(File.join( File.dirname(__FILE__), '..', '..', 'ar_spec_helper'))

describe Task do

  before do
    setup_testing_env
    @task_name = 'a_name'
    @now = Time.now
  end

  describe '#duration' do

    context 'task has start_at: 2010-05-10 13:45' do

      before do
        start_at = Time.parse('May 10 13:45:00 2010', @now)
        @task = Task.create :name => @task_name, :start_at => start_at.to_datetime, :date => start_at.to_date
      end

      context 'task has end_at: 2010-05-10 14:15:01' do

        before do
          now = Time.now
          @end_at = Time.parse('May 10 14:15:01 2010', @now)
          DateTime.stubs(:now => @end_at)
          Date.stubs(:today => @end_at.to_date)
          @task.stop
        end

        it 'should return 0h30m' do
          @task.duration.should == '0h30m'
        end
      end

      context 'task has end_at: 2010-05-10 15:20:01' do

        before do
          @end_at = Time.parse('May 10 15:20:01 2010', @now)
          DateTime.stubs(:now => @end_at)
          Date.stubs(:today => @end_at.to_date)
          @task.stop
        end

        it 'should return 1h35m' do
          @task.duration.should == '1h35m'
        end
      end

      context 'task has end_at: 2010-05-11 15:20:01' do

        before do
          @end_at = Time.parse('May 11 15:20:00 2010', @now)
          DateTime.stubs(:now => @end_at)
          Date.stubs(:today => @end_at.to_date)
          @task.stop
        end

        it 'should have 2 tasks with the same name' do
          Task.where(:name => @task_name).count.should == 2
        end

        it 'should return 11h15m for 2010-05-10' do
          date = Time.parse('2010-05-10', @now).to_date
          task = Task.where(:name => @task_name, :date => date).first
          task.duration.should == '10h14m'
        end

        it 'should return 14h35m' do
          @task.duration.should == '15h19m'
        end
      end

      context 'task has end_at: 2010-05-12 15:20:01' do

        before do
          @end_at = Time.parse('May 12 15:20:00 2010', @now)
          DateTime.stubs(:now => @end_at)
          Date.stubs(:today => @end_at.to_date)
          @task.stop
        end

        it 'should have 3 tasks with the same name' do
          Task.where(:name => @task_name).count.should == 3
        end

        it 'should return 11h15m for 2010-05-11' do
          date = Time.parse('2010-05-11', @now).to_date
          task = Task.where(:name => @task_name, :date => date).first
          task.duration.should == '23h59m'
        end

        it 'should return 11h15m for 2010-05-10' do
          date = Time.parse('2010-05-10', @now).to_date
          task = Task.where(:name => @task_name, :date => date).first
          task.duration.should == '10h14m'
        end

        it 'should return 14h35m' do
          @task.duration.should == '15h19m'
        end
      end
    end
  end
end
