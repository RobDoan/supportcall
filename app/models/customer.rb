class Customer < ApplicationRecord

	def self.lookup_by_twilio_respone(params, params_info)
		customer = find_or_initialize_by(phonenumber: params['From'])
		customer.location = params_info[:'geo-city']
		customer.name = params_info[:name] 
		customer.save
	end
end
