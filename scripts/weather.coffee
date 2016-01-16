# Description:
#   Tell us the weather in a random city
#
# Dependencies:
#  n/a
#
# Configuration:
#   n/a
#
#
# Commands:
#   hubot what's the weather like - Displays the weather for place where you are not likely to be
#

citiesInWhichIsocketHasNoEmployees = [
  'cleveland'
  'utica'
  'pensacola'
  'reno'
  'minot'
  'tacoma'
  'cheyenne'
  'richmond'
  'dublin'
  'chamonix'
  'truth%20or%20consequences'
  'split'
  'sandwich'
  'eddie'
  'cody'
  'denver'
  'boston'
  'durham'
  'arlington'
  'fort%20wayne'
  'bakersfield'
  'madison'
  'chula%20vista'
  'bismarck'
  'skokie'
  'springfield'
]

apiPath = 'http://api.openweathermap.org/data/2.5/weather'
apiKey = process.env.HUBOT_OPEN_WEATHER_API_KEY

module.exports = (robot) ->
  robot.respond /what[\'\’]s\s+the\s+weather\s+like/i, (msg) ->
    query = msg.random citiesInWhichIsocketHasNoEmployees
    robot.http("#{apiPath}?q=#{query}&APPID=#{apiKey}").get() (er, res, body) ->
      if er
        msg.send "Encountered an error: #{er}"
        return

      try
        weather = JSON.parse body
        # convert kelvin to farenheit
        # coffeelint: disable=max_line_length
        temp = (((weather.main.temp - 273.15) * 1.8) + 32).toString().split('.')[0]

        msg.send "It's about #{temp}ºF in #{weather.name}. #{weather.weather[0].description}."
        # coffeelint: enable=max_line_length
      catch err
        msg.send "Look outside"
