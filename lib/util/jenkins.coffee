URL  = require 'url'
xml2js = require 'xml2js'

JENKINS_IS_STUPID = ''

class JenkinsUtil
  constructor: (robot) ->
    unless process.env.HUBOT_JENKINS_URL
      throw new Error 'process.env.HUBOT_JENKINS_URL needed for jenkins scripts'

    jenkinsUrl = URL.parse process.env.HUBOT_JENKINS_URL

    @client = robot.http(process.env.HUBOT_JENKINS_URL).auth(jenkinsUrl.auth)

  _scope: (path, method, data, cb) ->
    unless cb
      cb = data
      data = JENKINS_IS_STUPID

    path = path.replace process.env.HUBOT_JENKINS_URL, ''

    @client.scope path, (cli) =>
      m = method.toLowerCase()

      if path.indexOf('json') > -1
        cli.header 'Accept', 'application/json'

      if path.indexOf('xml') > -1
        cli.header 'Content-Type', 'text/xml'

      cli[m](data) cb

  get: (path, cb) ->
    @_scope path, 'GET', cb

  post: (path, data, cb) ->
    @_scope path, 'POST', data, cb

  getJobsMatching: (re, cb) ->
    @get 'api/json', (err, statusCode, body) ->
      if err
        cb err
      else
        try
          content = JSON.parse body
          jobs = content.jobs.filter (job) -> re.test job.name

          cb null, jobs
        catch e
          cb e

  _branchConfig: (xml, branch, cb) ->
    unless cb
      cb = branch
      branch = false

    parser = new xml2js.Parser()

    parser.parseString xml, (err, json) ->
      if err
        cb err
      else
        try
          switch
            when json.project
              p = json.project.scm[0].branches[0]['hudson.plugins.git.BranchSpec'][0]

              if branch
                j = p
              else
                b = p.name[0]

            when json['maven2-moduleset']
              p = json['maven2-moduleset'].scm[0].branches[0]['hudson.plugins.git.BranchSpec'][0]

              if branch
                j = p
              else
                b = p.name[0]

            else
              throw new Error 'could not find branch. unknown config structure'
        catch e
          return cb e

        if branch
          if j.name[0] is branch
            return cb new Error branch + ' is already configured'
          else
            j.name = [branch]

          builder = new xml2js.Builder()
          cb null, builder.buildObject json
        else
          cb err, b

  getBranchNameFromConfig: (xml, cb) ->
    @_branchConfig xml, cb

  setBranchNameInConfig: (xml, branch, cb) ->
    @_branchConfig xml, branch, cb

module.exports = JenkinsUtil
