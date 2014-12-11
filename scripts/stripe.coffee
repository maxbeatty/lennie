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
    else
      false

module.exports = (robot) ->
  robot.router.post "/stripe", (req, res) ->
    robot.logger.debug req.body

    msg = proc req.body

    robot.messageRoom '1822_isocket_discussion@conf.hipchat.com', msg if msg

    res.end 'OK'

  robot.router.post "/stripe-test", (req, res) ->
    robot.logger.debug req.body

    msg = proc req.body

    robot.messageRoom '1822_dev_ops@conf.hipchat.com', 'TEST - ' + msg if msg

    res.end 'OK'
