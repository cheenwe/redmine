
require 'net/http'
require 'uri'

class MyScaffold < ActiveRecord::Base

	# url=http://openapi.baidu.com/public/2.0/bmt/translate?client_id=FZdVhFzQaWdLWzX9En8hHckY&q=断电报警内容,明天&from=zh&to=en
	#http://fanyi.youdao.com/openapi.do?keyfrom=cheenwe&key=742376919&type=data&doctype=json&version=1.1&only=translate&q=%E8%BD%A6%E7%89%8C%E5%8F%B7


	before_create :sys_string_name
	def sys_string_name
		self.result = MyScaffold.new.get_t(self.contact)
	end
#====================================百度翻译接口======================
  attr_accessor :host, :client_id, :from, :to

	def baidu_fanyi
 		YAML::load(File.open("#{Rails.root}/config/application.yml"))["baidu_fanyi"]
	end

	def host
		host = baidu_fanyi["host"]
	end

	def client_id
		client_id = baidu_fanyi["client_id"]
	end

	def from
		from = baidu_fanyi["from"]
	end

	def to
		to = baidu_fanyi["to"]
	end

	def data(date)
	  send_data.body
	  results = JSON.parse(send_data.body)
     @text = results["trans_result"][0]["dst"]
	end

	def get_t(contects)
		tmp_arr=[]
		contects.split(",").each do |contect|
			tmp_arr << send_data(contect).to_s.downcase.split.join("_").to_s
		end
		tmp_string=tmp_arr.to_s.delete "[" "]" '""' ","
		@result = tmp_string.to_s.gsub(":_",":")
	end

	#获取翻译数据
   def send_data(query)

	   query = 	CGI.escape(query)
	   @url = "#{baidu_fanyi["host"]}client_id=#{baidu_fanyi["client_id"]}&from=#{baidu_fanyi["from"]}&to=#{baidu_fanyi["to"]}&q=#{query}"
		uri = URI.parse @url

		http = Net::HTTP.new(uri.host, uri.port)
		request = Net::HTTP::Get.new(uri)

		data = http.request(request).body

		results = JSON.parse(data)
		results["trans_result"][0]["dst"]
	   rescue SocketError
		  puts "网络错误!"
   end

#==================================by chenwei 2015.10.14================
end
