# 邮件管理
path = require 'path'
nodemailer = require 'nodemailer'
smtpTransport = require 'nodemailer-smtp-transport'

module.exports = (setting, mailer) ->
  transporter = nodemailer.createTransport smtpTransport mailer.smtp

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
        root: if process.env.NODE_ENV is 'production' then path.join(setting.root, 'dist', 'views', 'email') else path.join(setting.root, 'views', 'email')
      , (err, render) =>
        return callback err, null if err
        render @template + '.html', @data, (err, html, text) =>
          return callback err, null if err
          transporter.sendMail
            from: mailer.from,
            to: fromTo,
            subject: @subject,
            text: text,
            html: html
          , (err, info) ->
            transporter.close()
            callback err, info if callback

  adou.mail = (subject, template, data) -> return new Mail subject, template, data
