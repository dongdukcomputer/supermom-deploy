

# -----------------------------------------
# blog 본문에 들어가 tag를 가져오는 메소드 시작

def get_tag(blog_link_uri)
	agent = Mechanize.new

	if blog_link_uri.include? "blog.me"
		html = agent.get(blog_link_uri)
		second_uri = html.search('frame').attr('src')
		page = agent.get(second_uri)
		page = page.search('frame').attr('src')
		blog_link_uri = "http://m.blog.naver.com" + page
	else
		blog_link_uri = blog_link_uri.gsub("http://", "http://m.")
	end

	page  = agent.get(blog_link_uri)
	
	page.search('div.post_tag').each do |t|
  		puts t.text.gsub('#', '')
  	end

	# 원래 페이지로 돌아가기
	return
end
# blog 본문에 들어가 tag를 가져오는 메소드 끝
# -----------------------------------------

require 'rubygems'
require 'mechanize'
require 'rest-client'

# main가져오기
agent = Mechanize.new
page = agent.get "http://naver.com"
search_form = page.form_with :name => "sform"
search_form.field_with(:name=>"query").value = "애착인형"
search_results = agent.submit search_form
main_uri = search_results.uri
# puts main_uri

# 메인에서 블로그 이동
page = agent.page.link_with(:text => '블로그').click


# 페이지를 5번째 페이지까지
for i in 2..5

	html = agent.get(page.uri).body
	html_doc = Nokogiri::HTML(html)
	blog_section = html_doc.css('ul#elThumbnailResultArea.type01')
	blog_head = blog_section.css('dt').css('a')
	blog_mini_content = blog_section.css('dd.sh_blog_passage')
	blog_date = blog_section.css('dd.txt_inline')

	# title 10개를 차례대로 뽑기
	blog_head.each_with_index do |v, i|
		puts v.attr('title')
	end

	# 소주제 10개를 차례대로 뽑기
	blog_mini_content.each_with_index do |v, i|
		puts v.text
	end

	# 블로그 본문으로 들어가기 
	page = agent.page.link_with(:text => '다음페이지').click

	
	for j in 1..9
		blog_link_uri = blog_head[j].attr('href')

		# 주소가 blog와 관련된 것만 태그를 뽑아옴 
		if blog_link_uri.include? "blog"
			get_tag(blog_link_uri)
		end	
	end
end
