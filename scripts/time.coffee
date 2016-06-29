# Description:
#   Tell us the days until RSUs vest
#
# Dependencies:
#  moment
#
# Configuration:
#   n/a
#
# Commands:
#   hubot what's the time - Displays the days until RSUs vest

moment = require 'moment'

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
# etc...
# ]

module.exports = (robot) ->
  robot.respond /what[\'\’]s\s+the\s+time/i, (msg) ->
    today = new Date()

    for d in vestDates
      if new Date(d) > today
        nextVest = d
        break

    future = moment(nextVest, "MM/DD/YYYY").fromNow()

    msg.send "Your next wave of RSUs vest #{future}"
