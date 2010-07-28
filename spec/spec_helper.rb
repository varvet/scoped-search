require 'ruby-debug'
require 'rspec'

require "active_record"

ActiveRecord::Schema.verbose = false
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

ActiveRecord::Base.configurations = true
ActiveRecord::Schema.define(:version => 1) do
  create_table :posts do |t|
    t.string :title
    t.text :body
    t.boolean :published

    t.timestamps
  end
end

require File.dirname(__FILE__) + '/../lib/scoped_search'

class Post < ActiveRecord::Base
  include ScopedSearch::Model
  
  scope :published, where(:published => true)
  scope :retrieve, lambda { |q| where("title like ?", "%#{q}%") }
  scope :retrieve_in_title_and_body, lambda { |a,b| where("title like ? and body like ?", "%#{a}%", "%#{b}") }
  scope :retrieve_ids, lambda { |ids| where(:id => ids) }
end

RSpec.configure do |config|
  config.mock_with :rspec
end

