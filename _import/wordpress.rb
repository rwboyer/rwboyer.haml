%w(rubygems dm-core fileutils yaml).each { |f| require f }

# NOTE: This converter requires Sequel and the MySQL gems.
# The MySQL gem can be difficult to install on OS X. Once you have MySQL
# installed, running the following commands should work:
# $ sudo gem install sequel
# $ sudo gem install mysql -- --with-mysql-config=/usr/local/mysql/bin/mysql_config

# Reads a MySQL database via Sequel and creates a post file for each
# post in wp_posts that has post_status = 'publish'.
# This restriction is made because 'draft' posts are not guaranteed to
# have valid dates.

require 'wp.rb'

dm = DataMapper.setup(:default, "mysql://root:@photo.rwboyer.com/wordpress")

FileUtils.mkdir_p "_posts"

blog = Post.all(:post_status => 'publish')

blog.each do |p|

	puts p.post_title

	# Get required fields and construct Jekyll compatible name

	title = p.post_title
	slug = p.post_name
	date = p.post_date
	content = p.post_content
	id = p.post_id
	name = "%02d-%02d-%02d-%s.markdown" % [date.year, date.month, date.day,
									   slug]
	# Get the relevant fields as a hash, delete empty fields and convert
	# to YAML for the header

	term_rels = TermRel.all(:post_id => p.post_id)
	post_terms = term_rels.term

	post_categories = post_terms.all(:termtax => { :tax => 'category' })

	c = []
	post_categories.each { |x| c << x.term_name }

	post_tags = post_terms.all(:termtax => { :tax => 'post_tag' })

	t = []
	post_tags.each { |x| t << x.term_name }

	data = {
	   'layout' => 'post',
	   'title' => title.to_s,
	   'wordpress_id' => id,
	   "tags" => t,
	   "categories" => c
	   #'wordpress_url' => post[:guid]
	 }.delete_if { |k,v| v.nil? || v == ''}.to_yaml

	# Write out the data and content to file
	File.open("_posts/#{name}", "w") do |f|
	  f.puts data
	  f.puts "---"
	  f.puts content
	end
end

