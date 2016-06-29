const Code = require('code')
const Lab = require('lab')
const mockery = require('mockery')
const Helper = require('hubot-test-helper')
const sinon = require('sinon')

const lab = exports.lab = Lab.script()
const expect = Code.expect

const mockS3 = {
  getSignedUrl: function () {}
}
const mockAws = {
  'S3': function () {
    return mockS3
  }
}

lab.experiment('dump', () => {
  var env
  var room
  var helper

  lab.before((done) => {
    mockery.registerMock('aws-sdk', mockAws)
    mockery.enable({
      warnOnUnregistered: false
    })

    env = JSON.stringify(process.env)

    process.env.DUMP_PRODUCTS = 'iris,rose'

    helper = new Helper('../../scripts/dump.coffee')

    done()
  })

  lab.after((done) => {
    mockery.disable()
    process.env = JSON.parse(env)

    done()
  })

  lab.beforeEach((done) => {
    room = helper.createRoom()

    sinon.spy(mockS3, 'getSignedUrl')

    done()
  })

  lab.afterEach((done) => {
    room.destroy()

    mockS3.getSignedUrl.restore()

    done()
  })

  lab.test('getting expiring signed url', (done) => {
    room.user.say('alice', 'hubot dump iris').then(() => {
      expect(room.messages).to.have.length(2)
      expect(room.messages[1][1]).to.startWith('Here')

      expect(mockS3.getSignedUrl.args[0][1]).to.include({ Expires: 600 })

      done()
    })
    .catch(done)
  })

  lab.test('specifying date', (done) => {
    room.user.say('alice', 'hubot dump iris 2016-04-01').then(() => {
      expect(mockS3.getSignedUrl.args[0][1]).to.include({
        Key: 'iris-2016-04-01.sql.gz'
      })

      done()
    })
    .catch(done)
  })

  lab.test('allows trailing space', (done) => {
    room.user.say('alice', 'hubot dump iris 2016-04-01 ').then(() => {
      expect(mockS3.getSignedUrl.args[0][1]).to.include({
        Key: 'iris-2016-04-01.sql.gz'
      })

      done()
    })
    .catch(done)
  })
})
