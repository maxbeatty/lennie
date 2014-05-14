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
