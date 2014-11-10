# Description:
#   Tell what branches are on the environment
#
# Dependencies:
#  xml2json
#
# Configuration:
#   HUBOT_JENKINS_URL
#
#
# Commands:
#   hubot what's on <env> - Displays which branch is configured to be deployed to playground for each job
#   hubot what's on <env> (for <repo>) - Displays which branch is configured to be deployed to playground for <repo>
#
# Notes:
#   HUBOT_JENKINS_URL should have any auth inline (e.g. https://user:pass@your.jenkins.url)

parser = require 'xml2json'
URL  = require 'url'
url  = URL.parse process.env.HUBOT_JENKINS_URL
HTTP = require url.protocol.replace(/:$/, '')

defaultOptions = () ->
  auth = new Buffer(url.auth).toString("base64")
  template =
    host: url.hostname
    port: url.port || 80
    path: url.pathname
    headers:
      "Authorization": "Basic #{auth}"

get = (path, params, cb) ->
  # params aren't currently used but will keep method signature the same for post, put, etc. in future

  options = defaultOptions()
  options.path += path

  req = HTTP.request options, (res) ->
    body = ""
    res.setEncoding "utf8"
    res.on "data", (chunk) ->
      body += chunk
    res.on "end", () ->
      cb null, res.statusCode, body

  req.on "error", (e) ->
    robot.emit 'error', e
    cb e, 500, "Client Error"

  req.end()

getJobConfig = (job, cb) ->
  res = job.name.replace(/-playground$/,'') + ': '
  path = URL.parse(job.url).path + 'config.xml'

  get path, {}, (err, statusCode, body) ->
    if err
      robot.emit 'error', err
      cb res + statusCode
    else
      try
        json = parser.toJson body, { object: true }

        branch = switch
          when json.project then json.project.scm.branches['hudson.plugins.git.BranchSpec'].name
          when json['maven2-moduleset'] then json['maven2-moduleset'].scm.branches['hudson.plugins.git.BranchSpec'].name
          else '(unknown project type)'

        cb res + branch

      catch e
        robot.emit 'error', e
        cb res + e.message

module.exports = (robot) ->
  robot.respond /what\'?s\s+on\s+([^? ]+)(\s+for\s+)?([^?]+)?.*/i, (msg) ->
    env = msg.match[1]
    preposition = msg.match[2] or ''# msg.match[2] will be " for ", if anything
    repo = msg.match[3] or ''
    summary = "Here are the branches currently on #{env + preposition + repo}: "

    if repo.length
      # check for specific repo
      name = "#{repo}-#{env}"
      job =
        name: name
        url: "#{url.href}job/#{name}/"

      getJobConfig job, (body) ->
        summary += '\n\t' + body

        msg.send summary

    else
      # check all repos
      get "/view/#{env}/api/json", {}, (err, statusCode, body) ->
        if err
          msg.send 'Jenkins says: ' + err
        else
          try
            content = JSON.parse body
            requestsRemaining = content.jobs.length

            for job in content.jobs
              getJobConfig job, (body) ->
                --requestsRemaining

                summary += '\n\t' + body

                msg.send summary unless requestsRemaining

          catch e
            msg.send e
