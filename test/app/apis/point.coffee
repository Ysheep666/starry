request = require 'supertest'

# 节点
# Post:/api/points/:id -- 更新节点

describe 'Api --> point controller', ->
  agent = request.agent require '../../../index'
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

  it 'Post:/api/points/:id -- 更新节点', (done) ->
    req = agent.post('/api/points/547ece8914a36a28576aa237').send
      title: '标题'
    req.cookies = cookies

    req.expect(202).end (err, res) ->
      return done err if err
      done()