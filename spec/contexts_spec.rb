require File.dirname(__FILE__) + '/spec_helper'

require 'contexts'

describe Contexts do
  attr_reader :test_object
  before(:each) do
    @test_object = Object.new
    class << test_object
      include Contexts
    end
  end
  describe "special context loading" do
    before(:each) do
      class << test_object
        load_context :title, 'exploration/band' do
          @test = 'test test'
        end
      end
    end
    it "should have added a method" do
      test_object.respond_to?(:load_context_data_for_title_exploration__band).should be_true
    end
    it "should not have added a caching method" do
      test_object.respond_to?(:context_cache_duration_for_title_exploration__band).should be_false
    end
  end
  describe "cached context loading" do
    before(:each) do
      class << test_object
        load_context :category, 'cached', :cache => 7.minutes do
          # load cached stuff
        end
      end
    end
    it "should create a cache duration method" do
      test_object.respond_to?(:context_cache_duration_for_category_cached).should be_true
    end
    it "should create a cache duration method that returns 7 minutes in seconds" do
      test_object.context_cache_duration_for_category_cached.should == 420
    end
  end
  describe "instance variable injection success" do
    before(:each) do
      class << test_object
        load_context :title, :profile do
          raise "should have instance variable @already_there" unless @already_there
        end
      end
    end
    it "should use instance variables of the passed in object" do
      @view_instance = Object.new
      @view_instance.instance_variable_set('@already_there', true)
      test_object.load_context_data_for_title_profile(@view_instance)
    end
  end
  describe "instance variable injection failure" do
    before(:each) do
      class << test_object
        load_context :title, :profile do
          raise "should have instance variable @already_there" unless @already_there
        end
      end
    end
    it "should fail because @already_there is not there" do
      @view_instance = Object.new
      lambda {
        test_object.load_context_data_for_title_profile(@view_instance)
      }.should raise_error(RuntimeError)
    end
  end
  describe "context loading" do
    before(:each) do
      class << test_object
        load_context :title, :profile do
          @test = 'test test'
        end
      end
    end
    it "should have added a method" do
      test_object.respond_to?(:load_context_data_for_title_profile).should be_true
    end
    describe "with no view instance instance variables" do
      before(:each) do
        test_object.load_context_data_for_title_profile(@view_instance)
      end
      it "should have an instance variable @test" do
        @view_instance.instance_variables.should include('@test')
      end
      it "should have an instance variable @test with 'test test' as value" do
        @view_instance.instance_variable_get(:@test).should == 'test test'
      end
    end
    describe "with view instance with instance variables" do
      before(:all) do
        @view_instance = Object.new
        @view_instance.instance_variable_set(:@test, 'test test')
        @view_instance.instance_variable_set(:@some_instance_variable, 'some instance variable')
      end
      it "should have an instance variable @test" do
        test_object.load_context_data_for_title_profile(@view_instance)
        @view_instance.instance_variables.should include('@test')
      end
      it "should have an instance variable @some_instance_variable" do
        test_object.load_context_data_for_title_profile(@view_instance)
        @view_instance.instance_variables.should include('@some_instance_variable')
      end
      it "should have an instance variable @test with value 'test test'" do
        test_object.load_context_data_for_title_profile(@view_instance)
        @view_instance.instance_variable_get(:@test).should == 'test test'
      end
      it "should have an instance variable @some_instance_variable with value 'some instance variable'" do
        test_object.load_context_data_for_title_profile(@view_instance)
        @view_instance.instance_variable_get(:@some_instance_variable).should == 'some instance variable'
      end
    end
  end
  describe "context types" do
    describe "category and block given" do
      before(:each) do
        class << test_object
          context :title do
            :profile
          end
        end
      end
      it "should have added a method" do
        test_object.respond_to?(:determine_context_type_for_title).should be_true
      end
      it "should set a context type for a context category" do
        test_object.determine_context_type_for_title.should == :profile
      end
    end
    describe "category and type given" do
      before(:each) do
        class << test_object
          context :title, :profile
        end
      end
      it "should have added a method" do
        test_object.respond_to?(:determine_context_type_for_title).should be_true
      end
      it "should return the type" do
        test_object.determine_context_type_for_title.should == :profile
      end
    end
    describe "category, default and actions given" do
      before(:each) do
        class << test_object
          attr_accessor :params
          context :title, :profile, [:muh, :gacker] => :farm, :meow => :house
        end
      end
      it "should have added a method" do
        test_object.respond_to? :determine_context_type_for_title
      end
      it "should return the default type without params" do
        test_object.determine_context_type_for_title.should == :profile
      end
      it "should return the default when action other that the above are given" do
        test_object.params = { :action => 'brzzt' }
        test_object.determine_context_type_for_title.should == :profile
      end
      it "should return a specific context if an action from the definition array is given" do
        test_object.params = { :action => 'muh' }
        test_object.determine_context_type_for_title.should == :farm
      end
      it "should return a specific context if a single defined action is given" do
        test_object.params = { :action => 'meow' }
        test_object.determine_context_type_for_title.should == :house
      end
    end

    it "should raise on no category" do
      lambda {
        class << test_object
          context
        end
      }.should raise_error(ArgumentError)
    end
    
  end
end
