# Description:
#   Tell us the days until RSUs vest
#
# Dependencies:
#  cheerio
#
# Configuration:
#   n/a
#
# Commands:
#   hubot what time is it - Displays the days until RSUs vest

cheerio = require 'cheerio'


# Build vest dates
DAY = 15 # vesting always happens on the 15th of the month
baseYear = 2016

VEST_YEARS = 4
VEST_TIMES = 2

vestDates = []

for i in [0..(VEST_YEARS * VEST_TIMES)]
  mdy = [
    if i % 2 then '11' else '05'
    DAY
    baseYear + Math.floor(i / 2)
  ]
  vestDates.push mdy.join('/')

# vestDates = [
#   '05/15/2016'
#   '11/15/2016'
#   '05/15/2017'
#   '11/15/2017'
# ]

module.exports = (robot) ->
  robot.respond /what[\'\’]s\s+the\s+time/i, (msg) ->
    today = new Date()

    for d in vestDates
      if new Date(d) > today
        nextVest = d
        break
    
    msg
      .http("https://daycalc.appspot.com/" + nextVest)
      .get() (err, res, body) ->
        return msg.send('Error: ' + err.message) if err

        $ = cheerio.load body

        msg.send "Only #{$('.du').text()} until your next wave of RSUs vest"
