request = require 'supertest'

# 故事
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

  it 'Get:/api/stories/:id -- 获取故事详情', (done) ->
    req = agent.get '/api/stories/5468c9fa3faec100000e23a8'
    req.cookies = cookies

    req.expect(200).end (err, res) ->
      return done err if err
      done()

  it 'Post:/api/stories/:id -- 更新故事详情', (done) ->
    req = agent.post('/api/stories/5468c9fa3faec100000e23a8').send
      background: 'http://starry-images.b0.upaiyun.com/201411/19/c1cc2b44e06ee12e783f60a81519bd86-41af1ae0f868005d.jpg'
    req.cookies = cookies

    req.expect(200).end (err, res) ->
      return done err if err
      done()
