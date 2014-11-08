# 邮件管理
path = require 'path'
nodemailer = require 'nodemailer'
smtpTransport = require 'nodemailer-smtp-transport'

module.exports = (config) ->
  transporter = nodemailer.createTransport smtpTransport(config.mailer.smtp)

  # 邮件管理
  class Mail
    # 构造函数
    # subject 标题
    # template 模板名称
    # data 模板参数
    constructor: (@subject, @template, @data) ->

    # 发送邮件
    send: (fromTo, callback) ->
      require('swig-email-templates')
        root: if process.env.NODE_ENV is 'production' then path.join(config.app.root, 'dist', 'views', 'email') else path.join(config.app.root, 'views', 'email')
      , (err, render) =>
        return callback err, null if err
        render @template + '.html', @data, (err, html, text) =>
          return callback err, null if err
          transporter.sendMail
            from: config.mailer.from,
            to: fromTo,
            subject: @subject,
            text: text,
            html: html
          , (err, info) ->
            transporter.close()
            callback err, info if callback

  adou.getMail = (subject, template, data) ->
    return new Mail subject, template, data
