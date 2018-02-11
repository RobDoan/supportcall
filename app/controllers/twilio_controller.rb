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
			timeout: 6) do |gather|
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
			dail(api_ai, response)
		elsif api_ai[:result][:fulfillment][:speech].empty? 	  	
			send_session(api_ai, response)
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

	def send_session(api_ai, twilio_response)
		if api_ai[:result][:action] == 'save_profile'
			twilio_response.say("Thank you for your information. 
				You profile already save on our server")	  	
		end
		twilio_response.gather(input: 'speech', 
			language: 'en-CA',
			action: '/ivr_response',
			timeout: 6) do |gather|
			gather.say("Do you need anything else?")
		end
	end

	def dail(api_ai, twilio_response)
		phone_number = api_ai[:result][:parameters][:"phone-number"]	
		if phone_number.empty?
			twilio_response.gather(input: 'speech', 
				language: 'en-CA',
				action: "/ivr_response/#{api_ai[:sessionId]}",
				timeout: 6, num_digits: 1) do |gather|
				gather.say(api_ai[:result][:fulfillment][:speech])  			

			else
				twilio_response.say("Wait a few seconds, we are connecting the call.")
				twilio_response.dial do |dial|
					dial.number(phone_number)
				end		
			end
		end
	end

	def api_ai_response(speech_result, session_id)
		api_ai_options = {client_access_token: '448a684f2b45415c9e94ea28f9e8d4df'}
		if session_id
			api_ai_options[:api_session_id] = session_id
		end
		@api = ApiAiRuby::Client.new(api_ai_options)
		@api.text_request(speech_result)
	end
end