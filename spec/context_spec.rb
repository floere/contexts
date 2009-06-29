require File.join(File.dirname(__FILE__), 'spec_helper')

require 'context'

describe Context do
  attr_reader :context

  before(:each) do
    @controller = mock :controller
    @view = mock :view
  end

  describe "type given" do
    it "should not use the controller to determine type" do
      @controller.should_receive(:send).with('determine_context_type_for_category').never
    end
    it "should generate a key from #context_cache_key" do
      context = Context.new @controller, @view, 'category', 'some_type'
      context.send(:cache_key).should == 'context/category/some_type'
    end
  end
  
  describe "with Context" do
    before(:each) do
      @context = Context.new @controller, @view, 'some_category', 'some_type'
    end
    describe "#render_content_for" do
      it "should render a partial" do
        @context.stub! :template_path => :some_template_path
        view = stub :view
        
        view.should_receive(:render).with :partial => :some_template_path
        
        in_the @context do
          render_content_for view
        end
      end
    end
    describe "#template_path" do
      it "should return a path consisting of contexts/category/type" do
        in_the @context do
          template_path.should == "contexts/some_category/some_type"
        end
      end
    end
  end

  describe "no type given" do
    before(:each) do
      @controller.should_receive(:determine_context_type_for_category).once.and_return 'dir/to/type'
    end
    it "should copy instance variables from the view into view_instance_variables" do
      view_instance = Object.new
      view_instance.instance_variable_set('@some_variable', 'some value')
      
      context = Context.new(@controller, view_instance, 'category')
      
      context.view_instance_variables['@some_variable'].should == 'some value'
    end
    describe "after new" do
      before(:each) do
        @context = Context.new(@controller, @view, 'category')
      end
      describe "enabled caching" do
        describe "caching" do
          before(:each) do
            @controller.should_receive(:respond_to?).
              with(:context_cache_duration_for_category_dir__to__type).once.and_return true
          end
          it "should use caching" do
            context.caching_enabled?.should be_true
          end
        end
        describe "cache" do
          it "should delegate writing the fragment to the controller" do
            cache_key = context.send(:cache_key)
            content = 'some content'
            @controller.should_receive(:write_fragment).once.with cache_key, content, :ttl => 420
            
            @controller.should_receive(:send).
              with(:context_cache_duration_for_category_dir__to__type).once.and_return 7.minutes
            
            context.cache content
          end
        end
      end
      describe "disabled caching" do
        before(:each) do
          @controller.should_receive(:respond_to?).with(:context_cache_duration_for_category_dir__to__type).once.and_return false
        end
        it "should not use caching" do
          context.caching_enabled?.should be_false
        end
      end
    end
  end
  
end