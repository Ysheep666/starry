request = require 'supertest'

# 项目
# Post:/api/projects -- 创建项目
# Post:/api/projects/:id/members -- 添加成员

describe 'Api --> project controller', ->
  agent = request.agent require('../../../app')
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

  it 'Post:/api/projects -- 创建项目', (done) ->
    req = agent.post('/api/projects')
    req.cookies = cookies

    req.send
      name: 'test1'
    .expect(201).end (err, res) ->
      return done err if err
      done()

  it 'Post:/api/projects/:id/members -- 添加成员', (done) ->
    req = agent.post('/api/projects/54509f2b9afc5a3b946a50cb/members')
    req.cookies = cookies

    req.send
      members: ['54509f44ea2a7e4c94b7a1cb']
    .expect(201).end (err, res) ->
      return done err if err
      done()
