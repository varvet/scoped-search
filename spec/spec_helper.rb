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
end

RSpec.configure do |config|
  config.mock_with :rspec
end
