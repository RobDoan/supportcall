require 'twilio-ruby'
require 'sanitize'

class TwilioController < ApplicationController
	skip_before_action :verify_authenticity_token

	def index
		
	end

	def welcome_ivr
		response = Twilio::TwiML::VoiceResponse.new
		response.gather(input: 'speech', 
						language: 'en-CA',
						action: '/ivr_response',
						timeout: 6, num_digits: 1) do |gather|
  			gather.say('Thanks for calling our services. What can I help you?')  			
		end
		render xml: response.to_s
	end

	def ivr_response
	  api_ai_session_id = params[:api_ai_session_id]	
	  speech_result = params[:SpeechResult]
	  api_ai = api_ai_response(speech_result, api_ai_session_id)

	  response = Twilio::TwiML::VoiceResponse.new		

	  if api_ai[:result][:action] == 'dial'
	  	phone_number = api_ai[:result][:parameters][:"phone-number"]
	  	if phone_number.empty?
	  		phone_number = '5142488681'
	  	end
	  	response.say("Wait a few seconds, we are connecting the call.")
	  	response.dial do |dial|
    		dial.number(phone_number)
		end
	  elsif api_ai[:result][:fulfillment][:speech].empty? 	  	
	  	Customer.lookup_by_twilio_respone(params, api_ai[:result][:parameters])	
	  	response.say("Thank you for your information. 
	  				You profile already save on our server")	  	
	  else
	  	response.gather(input: 'speech', 
	  					language: 'en-CA',
						action: "/ivr_response/#{api_ai[:sessionId]}",
						timeout: 6, num_digits: 1) do |gather|
  			gather.say(api_ai[:result][:fulfillment][:speech])  			
		end
	  end
	  	  
	  render xml: response.to_s
	end


	private 
	def api_ai_response(speech_result, session_id)
		api_ai_options = {client_access_token: '448a684f2b45415c9e94ea28f9e8d4df'}
		if session_id
			api_ai_options[:api_session_id] = session_id
		end
		@api = ApiAiRuby::Client.new(api_ai_options)
		@api.text_request(speech_result)
	end
end