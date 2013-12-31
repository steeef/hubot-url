// Description
//   fetch url, respond title and og:image
//
// Dependencies:
//
// Configuration:
//
// Commands:
//   ^https?://.*$ - respond title and og:image
//
// Notes:
//
// Author:
//   bouzuya <bouzuya@gmail.com>

var scraper = require('scraper');

var parseOgp = function($) {
  var ogp = {};
  $('meta').filter(function() {
    var property = $(this).attr('property');
    return /^og:.*$/.test(property);
  }).map(function() {
    var e = $(this);
    return {
      property: e.attr('property'),
      content: e.attr('content')
    };
  }).each(function() {
    // reduce ...
    var e = $(this).get(0);
    ogp[e.property.replace(/^og:/, '')] = e.content;
  });
  return ogp;
};

module.exports = function(robot) {
  robot.hear(/^(https?:\/\/.*)$/, function(msg) {
    var url = msg.match[1];
    // msg.send('fetching... ' + url);
    scraper(url, function(err, $) {
      if (err) throw err;
      var title = $('title').text();
      var ogp = parseOgp($);
      var t = title || ogp.title || 'no title';
      var i = ogp.image || '';
      msg.send(t + ' ' + i);
    });
  });
};
