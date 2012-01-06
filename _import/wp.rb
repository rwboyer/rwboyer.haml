require "rubygems"
require "dm-core"

#DataMapper.setup(:default, "mysql://root:@photo.rwboyer.com/wordpress")
$dm = DataMapper.setup(:default, "mysql://root:@photo.rwboyer.com/wordpress")

class Post
	include DataMapper::Resource
	
	storage_names[:default] = 'rb_posts'

	property :post_date, DateTime, :field => 'post_date'
	property :post_content, Text, :field => 'post_content'
	property :post_title, String, :field => 'post_title'
	property :post_name, String, :field => 'post_name'
	property :post_id, Serial, :field => 'ID', :key => true
	property :post_status, String, :field => 'post_status'

	has n, :termrels, :model => 'TermRel', :child_key => [ :post_id ]
	#has n, :tarms, :through => :termrels

end

class TermRel
	include DataMapper::Resource

	storage_names[:default] = "rb_term_relationships"

	property :post_id, Integer, :field => "object_id", :key => true
	property :term_id, Integer, :field => "term_taxonomy_id"

	has n, :posts 
	belongs_to :term, :child_key => [ :term_id ]

end

class Term
	include DataMapper::Resource

	storage_names[:default] = "rb_terms"

	property :term_id, Serial, :field => "term_id", :key => true
	property :term_name, String, :field => "name"

	has n, :termrels
	has n, :posts, :through => :termrels
	has n, :termtaxs, :model => 'TermTax', :child_key => [ :term_tax_id, :term_id ]

end

class TermTax
	include DataMapper::Resource

	storage_names[:default] = "rb_term_taxonomy"

	property :term_tax_id, Integer, :field => 'term_taxonomy_id', :key =>true
	property :term_id, Integer, :field => "term_id", :key => true
	property :tax, String, :field => "taxonomy"

	#belongs_to :term, :child_key => [ :term_id ]

end

