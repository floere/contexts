require File.join(File.dirname(__FILE__), 'spec_helper')

require 'context'

describe Context do
  attr_reader :context

  before(:each) do
    @controller_mock = flexmock(:controller)
    @view_mock = flexmock(:view)
  end

  describe "type given" do
    it "should not use the controller to determine type" do
      @controller_mock.should_receive(:send).with('determine_context_type_for_category').never
      
      Context.new(@controller_mock, @view_mock, 'category', 'some_type')
    end
    it "should generate a key from #context_cache_key" do
      context = Context.new(@controller_mock, @view_mock, 'category', 'some_type')
      context.send(:cache_key).should == 'context/category/some_type'
    end
  end

  describe "no type given" do
    before(:each) do
      @controller_mock.should_receive(:determine_context_type_for_category).once.and_return('dir/to/type')
    end
    it "should copy instance variables from the view into view_instance_variables" do
      view_instance = Object.new
      view_instance.instance_variable_set('@some_variable', 'some value')
      
      context = Context.new(@controller_mock, view_instance, 'category')
      
      context.view_instance_variables['@some_variable'].should == 'some value'
    end
    describe "after new" do
      before(:each) do
        @context = Context.new(@controller_mock, @view_mock, 'category')
      end
      describe "enabled caching" do
        describe "caching" do
          before(:each) do
            @controller_mock.should_receive(:respond_to?).
              with(:context_cache_duration_for_category_dir__to__type).once.and_return(true)
          end
          it "should use caching" do
            context.caching_enabled?.should be_true
          end
        end
        describe "cache" do
          it "should delegate writing the fragment to the controller" do
            cache_key = context.send(:cache_key)
            content = 'some content'
            @controller_mock.should_receive(:write_fragment).once.with(cache_key, content, :ttl => 420)
            
            @controller_mock.should_receive(:send).
              with(:context_cache_duration_for_category_dir__to__type).once.and_return(7.minutes)
            
            context.cache content
          end
        end
      end
      describe "disabled caching" do
        before(:each) do
          @controller_mock.should_receive(:respond_to?).with(:context_cache_duration_for_category_dir__to__type).once.and_return(false)
        end
        it "should not use caching" do
          context.caching_enabled?.should be_false
        end
      end
    end
  end
  
end