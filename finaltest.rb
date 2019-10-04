require "gelf"
require "excon"
require "rubygems"
require "json"
require 'net/http'
require 'open-uri'
#require "Down"
#what we have to parse 
#name = '{"response":[{"id":135919651,"first_name":"Андрей","last_name":"Грач","city":{"id":1,"title":"Москва"},"photo_max_orig":"https:\/\/sun9-63.userapi.com\/c850328\/v850328506\/132c9f\/j66i8Y9AIaE.jpg?ava=1","home_phone":"+7(977)799-79-82 мск"}]}'
class VKAPI
	#attr_accessor :result
	def user_info (userid, access_token)
	response = Excon.get("https://api.vk.com/method/users.get?user_ids=#{userid}&fields=photo_max_orig,city,contacts,
	has_photo&v=5.68&access_token=#{access_token}")
	@result = JSON.parse(response.body.force_encoding('utf-8'))["response"][0]

	Dir.mkdir("data") unless File.exists?("data")
	Dir.mkdir("pictures") unless File.exists?("pictures")
	data_path ="./data/savedata.txt"
	File.open(data_path, "a") { |file|
	#file.write(sprintf("ID:%d\nИмя:%s\nФамилия:%s\nГород:%s\nФото:%s\nНомер телефона:%s",result["id"],result["first_name"],result["last_name"],(result["city"]?result["city"]["title"]:""),result["photo_max_orig"],result["home_phone"]))
	file.write("ID: #{@result["id"].to_s}\n")
	file.write("Имя: #{@result["first_name"]}\n")
	file.write("Фамилия: #{@result["last_name"]}\n")
	file.write("Город: #{(@result["city"] ? @result["city"]["title"]:"Город не указан")}\n")
	file.write("Фото: #{@result["photo_max_orig"]}\n")
	file.write("Номер телефона: #{(@result["home_phone"] ? @result["home_phone"]:"Номер телефона не указан")}\n")
	file.write "="*80 + "\n"
	}
	pictures_path = "./pictures/newphoto.jpg"
	if @result["has_photo"] != 0
	File.open(@result["photo_max_orig"]) do |image|
	File.open(pictures_path, "wb") do |file|
		file.write(image.read)
	end
	end
	File.rename(pictures_path, "./pictures/#{@result['id']}")
	end
	end

	def graylog_city
		if @result["city"] == nil
			logger = GELF::Logger.new("syslog.synergy.ru", 12201, "WAN", { :facility => "test_city" })
			logger.info((@result["city"] ? @result["city"]["title"]:"Город не указан"))
	   	logger.close
		end
	end
 #TODO Сделать отправку в грейлог если номер телефона не Nil, а ""
	def graylog_phonenumber
		if @result["home_phone"] == nil || @result["home_phone"] == ""
		#logger = GELF::Logger.new("syslog.synergy.ru", 12201, "WAN", { :facility => "phone_number" })
		#logger.info((@result["home_phone"] ? @result["home_phone"]:"Номер телефона не указан"))
		#logger.close
		end
	end
end

	firstobject = VKAPI.new
	firstobject.user_info 13593, "b7caccad399f0c6e08ed4511279be4a30c35165b0d6ce46bc8b11bb3f806f01faad47e330aebacc30fd47"
	firstobject.graylog_city
  firstobject.graylog_phonenumber



#if result["photo_max_orig"] == "https:\/\/vk.com\/images\/camera_400.png?ava=1"
#File.delete("./pictures/#{result['id']}")
#
#







#first method


 





#url = 'https://vk.com';
#user2 = 'https://vk.com'

#function getUserDataVk($url){
#response
#result
#}

#result = getUserDataVk(url)
#result2 = getUserDataVk(user2)





#saveimage = puts result["response"].first["last_name"]

#second method with gem down
#Down.download(result["photo_max_orig"], destination: "./pictures")

























#multi_arr = [[1, 4, "Hello", "Andrey"]}, [-54, false, "Ruby"] ]
#puts multi_arr[data][3]