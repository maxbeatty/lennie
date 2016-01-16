const Code = require('code')
const Lab = require('lab')
const Helper = require('hubot-test-helper')
const nock = require('nock')
const path = require('path')

const lab = exports.lab = Lab.script()
const expect = Code.expect

lab.experiment('jenkins-env-branch script', () => {
  var room
  var helper
  var scope

  lab.before((done) => {
    process.env.HUBOT_JENKINS_URL = 'http://jenkins.url'
    helper = new Helper('../../scripts/jenkins-env-branch.coffee')

    done()
  })

  lab.beforeEach((done) => {
    room = helper.createRoom()
    scope = nock(process.env.HUBOT_JENKINS_URL)

    done()
  })

  lab.afterEach((done) => {
    room.destroy()

    done()
  })

  lab.test('error getting job', (done) => {
    scope.get('/job/repo-env/config.xml').replyWithError('oh boi')

    room.user.say('alice', "hubot what's on env for repo").then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        expect(room.messages[1][1]).to.contain('Error getting config')

        done()
      }, 10)
    })
  })

  lab.test('get all jobs', (done) => {
    scope
      .get('/api/json').reply(200, JSON.stringify({jobs: [
        {url: '/job/repo-a-env/', name: 'repo-a-env'},
        {url: '/job/repo-b-env/', name: 'repo-b-env'}
      ]}))
      .get('/job/repo-a-env/config.xml')
        .replyWithFile(200, path.resolve(__dirname, '../fixtures/config.xml'))
      .get('/job/repo-b-env/config.xml')
        .replyWithFile(200, path.resolve(__dirname, '../fixtures/config-java.xml'))

    room.user.say('bob', "hubot what's on env").then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        expect(room.messages[1][1].split('\n')).to.have.length(3)

        done()
      }, 10)
    })
  })

  lab.test('error getting jobs', (done) => {
    scope.get('/api/json').replyWithError('not right')

    room.user.say('alice', "hubot what's on env2").then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        expect(room.messages[1][1]).to.startWith('Error getting jobs')

        done()
      }, 10)
    })
  })

  lab.test('get all jobs', (done) => {
    scope.get('/job/repo-env/config.xml').reply(200, '<html></html>')

    room.user.say('bob', "hubot what's on env for repo").then(() => {
      setTimeout(() => {
        expect(room.messages).to.have.length(2)
        const reply = room.messages[1][1].split('\n')
        expect(reply).to.have.length(2)
        expect(reply[1]).to.contain('could not find branch')

        done()
      }, 10)
    })
  })
})
