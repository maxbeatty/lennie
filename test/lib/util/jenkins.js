const Code = require('code')
const Lab = require('lab')
const sinon = require('sinon')
const path = require('path')
const fs = require('fs')
const nock = require('nock')
const Hubot = require('hubot')

const lab = exports.lab = Lab.script()
const expect = Code.expect

const Jenkins = require('../../../lib/util/jenkins')

lab.experiment('jenkins utility library', () => {
  const robot = new Hubot.Robot('./adapters', 'shell')
  var j

  lab.beforeEach((done) => {
    process.env.HUBOT_JENKINS_URL = 'http://user:pass@jenkins.url'
    j = new Jenkins(robot)

    done()
  })

  lab.after((done) => {
    delete process.env.HUBOT_JENKINS_URL

    done()
  })

  lab.experiment('constructor', () => {
    lab.test('requires env var', (done) => {
      delete process.env.HUBOT_JENKINS_URL

      expect(() => new Jenkins()).to.throw(Error)

      done()
    })

    lab.test('constructs', (done) => {
      expect(j).to.be.instanceof(Jenkins)

      done()
    })
  })

  lab.experiment('_scope', () => {
    var scope

    lab.beforeEach((done) => {
      scope = nock('http://jenkins.url')

      done()
    })

    lab.test('simple request', (done) => {
      const path = '/api/json'
      scope
        .matchHeader('accept', 'application/json')
        .get(path)
        .reply(200, 'OK')

      j._scope(path, 'GET', (err, res, body) => {
        expect(err).to.be.null()

        done()
      })
    })

    lab.test('posting xml', (done) => {
      const path = '/job/testing/config.xml'
      const data = '<xml></xml>'
      scope
        .matchHeader('content-type', 'text/xml')
        .post(path, data)
        .reply(302, '')

      j._scope(path, 'POST', data, (err, statusCode, body) => {
        expect(err).to.be.null()

        done()
      })
    })
  })

  lab.experiment('get', () => {
    lab.test('calls scope', (done) => {
      sinon.stub(j, '_scope').callsArgWith(2, null)

      j.get('api', (err) => {
        expect(err).to.be.null()

        expect(j._scope.calledOnce).to.be.true()

        done()
      })
    })
  })

  lab.experiment('post', () => {
    lab.test('calls scope', (done) => {
      sinon.stub(j, '_scope').callsArgWith(3, null)

      j.post('api', {}, (err) => {
        expect(err).to.be.null()

        expect(j._scope.calledOnce).to.be.true()

        done()
      })
    })
  })

  lab.experiment('getJobsMatching', () => {
    lab.beforeEach((done) => {
      sinon.stub(j, 'get')

      done()
    })

    lab.test('calls get, filters jobs', (done) => {
      const body = {
        jobs: [
          { name: 'a-matches' },
          { name: 'b' },
          { name: 'c-matches' }
        ]
      }

      j.get.callsArgWith(1, null, 200, JSON.stringify(body))

      j.getJobsMatching(new RegExp('-matches$'), (err, jobs) => {
        expect(err).to.be.null()
        expect(jobs).to.be.an.array()
        expect(jobs).to.have.length(2)

        done()
      })
    })

    lab.test('catches error from get', (done) => {
      j.get.callsArgWith(1, new Error('testing'))

      j.getJobsMatching(new RegExp(''), (err) => {
        expect(err).to.be.instanceof(Error)
        expect(err.message).to.equal('testing')

        done()
      })
    })

    lab.test('catches error from parsing body', (done) => {
      j.get.callsArgWith(1, null, '')

      j.getJobsMatching(new RegExp(''), (err) => {
        expect(err).to.be.instanceof(Error)
        expect(err.message).to.include('Unexpected token')

        done()
      })
    })
  })

  lab.experiment('_branchConfig', () => {
    lab.test('finds branch name', (done) => {
      const xml = fs.readFileSync(path.resolve(__dirname, '../../fixtures/config.xml')).toString()
      j._branchConfig(xml, (err, branch) => {
        expect(err).to.be.null()

        expect(branch).to.equal('feature')

        done()
      })
    })

    lab.test('finds branch name for java', (done) => {
      const xml = fs.readFileSync(path.resolve(__dirname, '../../fixtures/config-java.xml')).toString()
      j._branchConfig(xml, (err, branch) => {
        expect(err).to.be.null()

        expect(branch).to.equal('feature')

        done()
      })
    })

    lab.test('returns error from parsing xml', (done) => {
      j._branchConfig({}, (err) => {
        expect(err).to.be.instanceof(Error)

        done()
      })
    })

    lab.test('returns error from reaching into json', (done) => {
      j._branchConfig(new Buffer(''), (err) => {
        expect(err).to.be.instanceof(Error)

        done()
      })
    })

    lab.test('returns error when unknown xml struct', (done) => {
      j._branchConfig('<html></html>', (err) => {
        expect(err).to.be.instanceof(Error)

        done()
      })
    })

    lab.experiment('set branch', () => {
      lab.test('for common', (done) => {
        const xml = fs.readFileSync(path.resolve(__dirname, '../../fixtures/config.xml')).toString()
        j._branchConfig(xml, 'master', (err, xmlModified) => {
          expect(err).to.be.null()

          done()
        })
      })

      lab.test('for java', (done) => {
        const xml = fs.readFileSync(path.resolve(__dirname, '../../fixtures/config-java.xml')).toString()
        j._branchConfig(xml, 'master', (err, xmlModified) => {
          expect(err).to.be.null()

          done()
        })
      })

      lab.test('already set', (done) => {
        const xml = fs.readFileSync(path.resolve(__dirname, '../../fixtures/config.xml')).toString()
        j._branchConfig(xml, 'feature', (err) => {
          expect(err).to.be.instanceof(Error)
          expect(err.message).to.include('already configured')

          done()
        })
      })
    })
  })

  lab.experiment('getBranchNameFromConfig', () => {
    lab.test('calls _branchConfig', (done) => {
      sinon.stub(j, '_branchConfig').callsArgWith(1, null)

      j.getBranchNameFromConfig('', (err) => {
        expect(err).to.be.null()
        expect(j._branchConfig.calledOnce).to.be.true()

        done()
      })
    })
  })

  lab.experiment('setBranchNameInConfig', () => {
    lab.test('calls _branchConfig', (done) => {
      sinon.stub(j, '_branchConfig').callsArgWith(2, null)

      j.setBranchNameInConfig('', '', (err) => {
        expect(err).to.be.null()
        expect(j._branchConfig.calledOnce).to.be.true()

        done()
      })
    })
  })
})
