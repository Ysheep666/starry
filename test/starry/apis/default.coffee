request = require 'supertest'

# 默认
# Get:/api/stories -- 获取故事列表

describe 'Api --> story controller', ->
  agent = request.agent require '../../../app'
  cookies = ''

  # 获取 Cookie
  before (done) ->
    agent.post('/api/signin').send
      email: 'test@test.com'
      password: 'test'
    .end (err, res) ->
      return done err if err
      cookies = res.headers['set-cookie'].pop().split(';')[0]
      done()

  it 'Get:/api/stories -- 获取故事列表', (done) ->
    req = agent.get '/api/stories'
    req.cookies = cookies

    req.expect(200).end (err, res) ->
      return done err if err
      done()
