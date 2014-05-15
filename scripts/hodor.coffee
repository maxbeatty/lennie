# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hodor - says 'hodor'
#
# Author:
#   brianstarke

module.exports = (robot) ->
  robot.hear /hodor/i, (msg) ->
    msg.send 'hodor'

  robot.hear /science/i, (msg) ->
    msg.send 'http://i.imgur.com/eXX4SyK.gif'


