request = require 'supertest'

# 故事
# Post:/api/stories -- 新建故事
# Delete:/api/stories/:id -- 删除故事
# Patch:/api/stories/:id -- 更新故事
# Post:/api/stories/:id -- 更新故事简介
# Post:/api/stories/:id/sections -- 新建故事片段
# Delete:/api/stories/:id/sections/:id -- 删除故事片段
# Get:/api/stories -- 获取故事列表
# Get:/api/stories/:id -- 获取故事详情

describe 'Api --> story controller', ->
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

  it 'Post:/api/stories -- 新建故事', (done) ->
    req = agent.post '/api/stories'
    req.cookies = cookies

    req.expect(201).end (err, res) ->
      return done err if err
      done()

  it 'Delete:/api/stories/:id -- 删除故事', (done) ->
    req = agent.delete '/api/stories/546d84668bcbbc00005bcd5d'
    req.cookies = cookies

    req.expect(202).end (err, res) ->
      return done err if err
      done()

  it 'Patch:/api/stories/:id -- 更新故事', (done) ->
    req = agent.patch('/api/stories/5468c9fa3faec100000e23a8').send
      background: 'http://starry-images.b0.upaiyun.com/201411/19/c1cc2b44e06ee12e783f60a81519bd86-41af1ae0f868005d.jpg'
    req.cookies = cookies

    req.expect(202).end (err, res) ->
      return done err if err
      done()

  it 'Post:/api/stories/:id -- 更新故事简介', (done) ->
    req = agent.post('/api/stories/5468c9fa3faec100000e23a8').send
      title: '故事标题'
      mark: 'url'
    req.cookies = cookies

    req.expect(202).end (err, res) ->
      return done err if err
      done()

  it 'Post:/api/stories/:id/sections -- 新建故事片段', (done) ->
    req = agent.post('/api/stories/5468c9fa3faec100000e23a8/sections').send
      title: '名称'
    req.cookies = cookies

    req.expect(201).end (err, res) ->
      return done err if err
      done()

  it 'Delete:/api/stories/:id/sections/:id -- 删除故事片段', (done) ->
    req = agent.delete '/api/stories/5468c9fa3faec100000e23a8/sections/546ed951f517a1589e49748d'
    req.cookies = cookies

    req.expect(202).end (err, res) ->
      return done err if err
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
