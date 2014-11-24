request = require 'supertest'

# 默认
# Post:/api/upyun_token -- 获取又拍云 Token 信息
# Get:/api/me -- 获取个人信息
# Post:/api/signin -- 登录
# Delete:/api/signin -- 退出
# Post:/api/signup -- 注册
# Post:/api/forgot -- 找回密码

describe 'Api --> default controller', ->
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

  it 'Post:/api/signup -- 注册', (done) ->
    agent.post('/api/signup').send
      name: '测试2'
      email: 'test2@test.com'
      password: 'test'
    .expect(201).end (err, res) ->
      return done err if err
      done()

  it 'Get:/api/me -- 获取个人信息', (done) ->
    req = agent.get '/api/me'
    req.cookies = cookies

    req.expect(200).end (err, res) ->
      return done err if err
      done()

  it 'Post:/api/upyun_token -- 获取又拍云 Token 信息', (done) ->
    req = agent.post('/api/upyun_token').send
      bucket: 'starry-images'
      expiration: parseInt (new Date().getTime() + 600000)/1000, 10
      'save-key': '/{year}{mon}/{day}/{filemd5}-{random}{.suffix}'
    req.cookies = cookies

    req.expect(200).end (err, res) ->
      return done err if err
      done()
