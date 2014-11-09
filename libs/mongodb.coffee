# MongoDB 管理
mongodb = require 'mongodb'

{MongoClient} = mongodb

env = process.env.NODE_ENV or 'development'

module.exports = (db) ->
  {url} = db.mongodb

  adou.getDatabase = ->
    _database =
      # 获取数据库连接
      connect: (callback) ->
        MongoClient.connect url, callback

      # 创建数据
      create: (collectionName, doc, options, callback) ->
        if typeof options is 'function'
          callback = options
          options = { w: 1 }

        @connect (err, db) ->
          if err
            db.close()
            return callback err

          collection = db.collection collectionName
          collection.insert doc, options, (err, results) ->
            db.close()
            callback err, results[0]

      # 删除数据
      remove: (collectionName, query, options, callback) ->
        if typeof options is 'function'
          callback = options
          options = { w: 1 }

        @connect (err, db) ->
          if err
            db.close()
            return callback err

          collection = db.collection collectionName
          collection.remove query, options, (err, result) ->
            db.close()
            callback err, result

      # 更新数据
      update: (collectionName, query, doc, options, callback) ->
        if typeof options is 'function'
          callback = options
          options = { w: 1 }

        @connect (err, db) ->
          if err
            db.close()
            return callback err

          collection = db.collection collectionName
          collection.update query, doc, options, (err, result) ->
            db.close()
            callback err, result

      # 统计数据
      count: (collectionName, query, callback) ->
        @connect (err, db) ->
          if err
            db.close()
            return callback err

          collection = db.collection collectionName
          collection.count query, (err, count) ->
            db.close()
            callback err, count

      # 查找数据
      find: (collectionName, query, options, callback) ->
        if typeof options is 'function'
          callback = options
          options = {}

        @connect (err, db) ->
          if err
            db.close()
            return callback err

          collection = db.collection collectionName
          collection.find(query, options).toArray (err, results) ->
            db.close()
            callback err, results

      # 查找单个数据
      findOne: (collectionName, query, options, callback) ->
        if typeof options is 'function'
          callback = options
          options = {}

        @connect (err, db) ->
          if err
            db.close()
            return callback err

          collection = db.collection collectionName
          collection.findOne query, options, (err, result) ->
            db.close()
            callback err, result

    return _database
