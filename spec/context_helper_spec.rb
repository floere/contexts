require File.join(File.dirname(__FILE__), 'spec_helper')

require 'context_helper'

describe 'ContextHelper' do

  include ContextHelper
  
  describe "#render_context" do
    describe "no category given" do
      it "should not do anything" do
        render_context(nil).should == nil
      end
    end
    describe "category given, but no type" do
      before(:each) do
        context = flexmock(Context)
        @context_instance = flexmock(:context)
        context.should_receive(:new).once.and_return(@context_instance)
      end
      it "should call the render method on the context" do
        @context_instance.should_receive(:render).once
        render_context(:title)
      end
    end
    describe "category and type given" do
      before(:each) do
        context = flexmock(Context)
        @context_instance = flexmock(:context)
        context.should_receive(:new).once.and_return(@context_instance)
      end
      it "should call the render method on the context" do
        @context_instance.should_receive(:render).once
        render_context(:title, :profile)
      end
    end
  end
end