# Description:
#   Retrieve signed URLs from AWS S3
#
# Dependencies:
#  aws-sdk
#
# Configuration:
#   AWS_ACCESS_KEY_ID
#   AWS_SECRET_ACCESS_KEY
#   AWS_S3_BUCKET
#   DUMP_PRODUCTS
#
# Commands:
#   hubot dump <app> <day> - Gives you a download URL.
#   `<day>` is optional and defaults to today
#   (e.g. `hubot dump iris` will give you today's dump while
#   `hubot dump sclera 2016-04-01` will give you the dump from April 1st, 2016)

AWS = require 'aws-sdk'

s3 = new AWS.S3({
  apiVersion: '2006-03-01'
})

padZero = (num) ->
  if num.toString().length is 1 then '0' + num else num

getToday = ->
  d = new Date()
  d.getFullYear() + '-' + padZero(d.getMonth() + 1) + '-' + padZero(d.getDate())

products = process.env.DUMP_PRODUCTS.split(',').join('|')
re = new RegExp "dump (" + products + ")\\s?(\\d{4}-\\d{2}-\\d{2})?.*"

module.exports = (robot) ->
  robot.respond re, (msg) ->
    product = msg.match[1]
    day = msg.match[2] or getToday()

    signedUrl = s3.getSignedUrl('getObject', {
      Bucket: process.env.AWS_S3_BUCKET,
      Key: "#{product}-#{day}.sql.gz",
      Expires: 600 # seconds (10 minutes)
    })

    msg.send "Here's a download link that expires in 10 minutes: " + signedUrl
