# Api 接口

### 默认
- Post:/api/upyun_token -- 获取又拍云 Token 信息
- Post:/api/signup -- 注册
- Post:/api/forgot -- 找回密码
- Post:/api/signin -- 登录
- Delete:/api/signin -- 退出
- Get:/api/me -- 获取个人信息


### 故事
- Post:/api/stories -- 新建故事
- Delete:/api/stories/:id -- 删除故事
- Patch:/api/stories/:id -- 更新故事
- Post:/api/stories/:id -- 更新故事简介
- Post:/api/stories/:id/sections -- 新建故事片段
- Get:/api/stories -- 获取故事列表
- Get:/api/stories/:id -- 获取故事详情


### 片段
- Post:/api/sections/:id/points -- 新建故事节点
