require 'rest_client'
require 'json'

# Before running this, must create an iNat application here:
# https://www.inaturalist.org/oauth/applications/new

site = "https://www.inaturalist.org"
app_id = ENV['INAT_APP_ID']
app_secret = ENV['INAT_APP_SECRET']
# redirect_uri = 'YOUR APP REDIRECT URI' # you can set this to some URL you control for testing
username = ENV['INAT_USERNAME']
password = ENV['INAT_PASSWORD']

# Send a POST request to /oauth/token with the username and password
payload = {
  :client_id => app_id,
  :client_secret => app_secret,
  :grant_type => "password",
  :username => username,
  :password => password
}
puts "POST #{site}/oauth/token, payload: #{payload.inspect}"
response = RestClient.post("#{site}/oauth/token", payload)
puts "RESPONSE"
puts response
puts
# response will be a chunk of JSON looking like
# {
#   "access_token":"xxx",
#   "token_type":"bearer",
#   "expires_in":null,
#   "refresh_token":null,
#   "scope":"write"
# }

# Store the token (access_token) in your app. You can now use it to make authorized
# requests on behalf of the user, like retrieving profile data:
token = JSON.parse(response)["access_token"]
headers = {"Authorization" => "Bearer #{token}"}
puts "GET /users/edit.json, headers: #{headers.inspect}"
puts "RESPONSE"
puts RestClient.get("#{site}/users/edit.json", headers)
puts
