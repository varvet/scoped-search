require "spec_helper"

%w(blahblah foo bar pipo waouhhh pipomolo).each do |title|
  Post.create(:title => title, :body => "blah", :published => title.include?("pipo"))
end

Post.create(:title => "test multi params", :body => "this is to test multi params, whaaaa")

describe 'ScopedSearch' do
  it 'should respond to scoped_search and return a ScopedSearch::Base object' do
    Post.should respond_to(:scoped_search)
    Post.scoped_search.should be_a(ScopedSearch::Base)
  end
  
  it 'should have the same count when initializing an empty search' do
    Post.count.should == 7
    
    @search = Post.scoped_search
    @search.count.should == 7
  end
  
  describe 'initialization' do
    it 'should be possible to initialize without a hash and change attributes later' do
      @search = Post.scoped_search
      @search.attributes.should == {}
      
      @search.retrieve = "pipo"
      @search.published = true
      @search.attributes.should have(2).elements
      @search.attributes[:retrieve].should == "pipo"
      @search.attributes[:published].should == true
    end
    
    it 'should be possible to initialize with a hash' do
      @search = Post.scoped_search({ :retrieve => "pipo", :published => true })
      @search.attributes.should have(2).elements
      
      @search.retrieve.should == "pipo"
      @search.published.should == true
    end
  end
  
  describe 'searching' do
    it 'should be possible to search with one parameter' do
      @search = Post.scoped_search({ :retrieve => "foo" })
      @search.retrieve.should == "foo"
      @search.count.should == 1
      
      @search.all.should have(1).element
      @search.retrieve = nil
      @search.count.should == 7
    end
    
    it 'should be possible to search with multiple parameters' do
      @search = Post.scoped_search({ :retrieve => "foo", :published => true })
      @search.retrieve.should == "foo"
      @search.published.should == true
      @search.count.should == 0
      
      @search.all.should have(0).element
      @search.retrieve = nil
      @search.count.should == 2
      @search.all.should have(2).elements
    end
    
    it 'should be possible to search in a multi params scope' do
      @search = Post.scoped_search
      
      @search.retrieve_in_title_and_body = ["test", "whaaaa"]
      @search.retrieve_in_title_and_body_multi_params = true
      @search.count.should == 1
      
      @search = Post.scoped_search({ :retrieve_in_title_and_body => ["test", "whaaaa"], :retrieve_in_title_and_body_multi_params => "true" })
      @search.count.should == 1
    end
    
    it 'should be possible to search in a scope that wants an Array' do
      @search = Post.scoped_search

      @search.retrieve_ids = ["3", "4"]
      @search.count.should == 2
      
      @search = Post.scoped_search({ :retrieve_ids => ["3", "4"] })
      @search.count.should == 2
    end
  end
  
  it 'should be possible to build the relation' do
    @search = Post.scoped_search({ :retrieve => "foo" })
    @search.build_relation.should be_a(ActiveRecord::Relation)
  end
end
