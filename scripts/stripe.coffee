# Description:
#   Webhook for Stripe.com events
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Notes:
#   None

proc = (evt) ->
  switch evt.type
    when 'charge.succeeded'
      amt = parseFloat(evt.data.object.amount / 100).toFixed(2)
      "$#{amt} CC payment received for #{evt.data.object.metadata.orderUid}"
    when 'ping'
      'friendly ping to see if webhook is working'

module.exports = (robot) ->
  robot.router.post "/stripe", (req, res) ->
    robot.logger.debug req.body

    # isocket Discussion
    robot.messageRoom 2944, proc(req.body)

    res.end 'OK'

  robot.router.post "/stripe-test", (req, res) ->
    robot.logger.debug req.body

    # Engineering Only
    robot.messageRoom 6394, 'TEST - ' + proc(req.body)

    res.end 'OK'
