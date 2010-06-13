require 'mocha'
require File.join( File.dirname(__FILE__), '..', '..', 'datamapper_spec_helper')

describe Rtt::Task do

  before do
    Rtt.init(:test)
    Rtt.migrate
  end

  describe '#duration' do

    context 'task has start_at: 2010-05-10 13:45' do

      before do
        @task = Rtt::Task.create :name => 'a_name', :start_at => DateTime.new(2010, 5, 10, 13, 45, 0)
      end

      context 'task has end_at: 2010-05-10 14:15' do

        before do
          @task.end_at = DateTime.new(2010, 5, 10, 14, 15, 0)
          @task.save
        end

        it 'should return 0h30m' do
          @task.duration.should == '0h30m'
        end
      end

      context 'task has end_at: 2010-05-10 15:20' do

        before do
          @task.end_at = DateTime.new(2010, 5, 10, 15, 20, 0)
          @task.save
        end

        it 'should return 1h35m' do
          @task.duration.should == '1h35m'
        end
      end

      context 'task has end_at: 2010-05-11 15:20' do

        before do
          @task.end_at = DateTime.new(2010, 5, 11, 15, 20, 0)
          @task.save
        end

        it 'should return 25h35m' do
          @task.duration.should == '25h35m'
        end
      end

      context 'no end_at is defined.' do

        before do
          @task.end_at = nil
          @task.save
          DateTime.stubs(:now => DateTime.new(2010, 5, 10, 13, 50, 0))
        end

        it 'should use current time' do
          @task.duration.should == '0h5m'
        end
      end
    end
  end
end
