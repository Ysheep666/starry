request = require 'supertest'

# 片段
# Post:/api/sections/:id -- 更新片段
# Post:/api/sections/:id/points -- 新建故事节点
# Delete:/api/sections/:id/points/:id -- 删除故事节点

describe 'Api --> section controller', ->
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

  it 'Post:/api/sections/:id -- 更新片段', (done) ->
    req = agent.post('/api/sections/546ed951f517a1589e49748d').send
      title: '标题'
    req.cookies = cookies

    req.expect(202).end (err, res) ->
      return done err if err
      done()

  it 'Post:/api/sections/:id/points -- 新建故事节点', (done) ->
    req = agent.post('/api/sections/546ed951f517a1589e49748d/points').send
      title: '标题'
    req.cookies = cookies

    req.expect(201).end (err, res) ->
      return done err if err
      done()

  it 'Delete:/api/sections/:id/points/:id -- 删除故事节点', (done) ->
    req = agent.delete '/api/sections/546ed951f517a1589e49748d/points/547dda656f9f160000c53feb'
    req.cookies = cookies

    req.expect(202).end (err, res) ->
      return done err if err
      done()
