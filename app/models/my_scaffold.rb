
require 'net/http'
require 'uri'

class MyScaffold < ActiveRecord::Base

   # Host = "http://openapi.baidu.com/public/2.0/bmt/translate?client_id=FZdVhFzQaWdLWzX9En8hHckY"

	# url=http://openapi.baidu.com/public/2.0/bmt/translate?client_id=FZdVhFzQaWdLWzX9En8hHckY&q=断电报警内容,明天&from=auto&to=auto

  attr_accessor :host, :client_id, :from, :to

	def baidu_fanyi
 		YAML::load(File.open("#{Rails.root}/config/application.yml"))["baidu_fanyi"]
	  # host = @fanyi["host"]
	  # client_id = @fanyi["client_id"]
	  # from = @fanyi["from"]
	  # to = @fanyi["to"]
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

	def get_this
		CGI.escape("明天/你好/哈哈/")
	end

	def url
	   @url = "#{baidu_fanyi["host"]}client_id=#{baidu_fanyi["client_id"]}&from=#{baidu_fanyi["from"]}&to=#{baidu_fanyi["to"]}&q=#{get_this}"
	rescue
	  puts "参数错误!"
	end

	def data(date)
	  send_data.body
	  results = JSON.parse(send_data.body)
     @text = results["trans_result"][0]["dst"]
	end


	#调用翻译数据并处理
	#
	# 车牌号:varchar,所属类型:varchar,驾驶员:varchar,当前位置:varchar,待派状态:varchar,驾驶员电话:varcha,派度地址:varchar,定时短信:Date   ,客户代码:varchar,客户电话:varchar,门点 :varchar,剩余距离:double ,剩余时间:varchar,备注 :varchar
	# def method_name(input)
	# 	date =
	# 	# MyScaffold.new.send_data("我去,你去,你好,大家好").split(",").each do |a| puts  a.to_s.downcase.split.join("_") end

	# end
	def get_value(a,t)
		str  = t.split(",")
		arr=[]
		a = send_data(a).split(",").each do |b|
			arr << b.to_s.downcase.split.join("_")
		end
		puts arr
		puts str
		puts arr + str
	end

	#获取翻译数据
   def send_data(query)
   	# .split(",")
   	# downcase​.split.join("_")
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

   # def call
   #   results = JSON.parse(@text)
   #   @text = results["trans_result"][0]["dst"]
   #   puts @text
   # rescue

   #   if results["error_code"] == "52001"
   #    puts "糟糕，请求超时咯^^"
   #   end

   #   if results["error_code"] == "52002"
   #    puts "糟糕，系统出错咯^^"
   #   end

   #   if results["error_code"] == "52003"
   #    puts "请检查API KEY是否正确^^"
   #   end

   #   if results["error_code"] == "52004"
   #    puts "参数错误～～"
   #   end
   # end

end
