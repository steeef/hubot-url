# Description
#   fetch url, respond title and og:image
#
# Dependencies:
#   "cheerio": "0.17.0"
#
# Configuration:
#   HUBOT_URL_IGNORE_PATTERNS - a regexp to ignore certain urls
#   HUBOT_URL_IGNORE_USERS - ignore from specific users (e.g., JIRA)
#
# Commands:
#   ^https?://.*$ - respond title and og:image
#
# Author:
#   bouzuya <m@bouzuya.net>

cheerio = require 'cheerio'

parseOgp = ($) ->
  ogp = {}
  $('meta')
    .filter ->
      e = $(@)
      property = e.attr 'property'
      /^og:.*$/.test property
    .map ->
      e = $(@)
      {
        property: e.attr('property').replace(/^og:/, '')
        content: e.attr 'content'
      }
    .each ->
      ogp[@property] = @content
  ogp

module.exports = (robot) ->
  ignore_users = process.env.HUBOT_URL_IGNORE_USERS.split(',') or '[]'
  ignore_pattern = process.env.HUBOT_URL_IGNORE_PATTERNS

  robot.hear /^(https?:\/\/.*)$/, (msg) ->

    url = msg.match[1]

    # ignore users
    username = msg.message.user.name
    if username in ignore_users
      console.log 'ignoring user due to blacklist: ', username
      return

    # filter out some common files first
    ignore = url.match(/\.(png|jpg|jpeg|gif|txt|zip|tar\.bz|js|css)/)
    if !ignore && ignore_pattern
      ignore = url.match(ignore_pattern)

    unless ignore
      msg
        .http(url)
        .get() (err, res, body) ->
          throw err if err
          $ = cheerio.load body
          title = $('title').text()
          ogp = parseOgp $
          t = title or ogp.title or null
          i = ogp.image or null
          msg.send(t) if t?
          msg.send(i) if i?
