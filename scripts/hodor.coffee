# Description:
#   None
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hodor - says 'hodor'
#
# Author:
#   brianstarke

scienceGifs = [
  'http://media.giphy.com/media/awuA6yBdZdOpy/giphy.gif'
  'http://i.imgur.com/eXX4SyK.gif'
  'http://media.giphy.com/media/En0rwC2l5WCxa/giphy.gif'
  'http://media.giphy.com/media/a0q8vE3WKTIzK/giphy.gif'
  'http://i0.kym-cdn.com/photos/images/original/000/544/203/a03.jpg'
  'http://i2.kym-cdn.com/photos/images/original/000/544/282/f9b.png'
  'http://i0.kym-cdn.com/photos/images/original/000/658/359/54d.jpg'
  'http://24.media.tumblr.com/tumblr_m2y038gsvB1qjxjwto1_500.gif'
  'http://i0.kym-cdn.com/photos/images/original/000/544/157/03e.jpg'
  'http://i3.kym-cdn.com/photos/images/original/000/544/415/e83.png'
  'http://31.media.tumblr.com/tumblr_m3nr1tCIJ61ruj0yho1_100.gif'
  'http://37.media.tumblr.com/tumblr_m3nqwqEnHa1ruj0yho1_100.gif'
  'http://37.media.tumblr.com/tumblr_m3nqh2Xy3d1ruj0yho1_500.gif'
  'http://24.media.tumblr.com/tumblr_m3nq210MUy1ruj0yho1_400.gif'
  'http://31.media.tumblr.com/tumblr_m356dxsa301ruj0yho1_400.gif'
  'http://24.media.tumblr.com/tumblr_lvpb2ty0z71qfr9vzo1_500.gif'
  'http://img.pandawhale.com/post-29085-Jesse-Pinkman-YEAH-SCIENCE-gif-2wAB.gif'
  'http://media.giphy.com/media/NR14ZNitY4MGk/giphy.gif'
  'http://fc03.deviantart.net/fs71/f/2012/359/a/0/science_animated_gif_by_mysteriousshamrock-d5p3shf.gif'
  'http://media2.giphy.com/media/ydMNTWYVjSEFi/giphy.gif'
  'http://media3.giphy.com/media/13Crr6gkUCCEWA/giphy.gif'
  'https://webfiles.uci.edu/tlentz/home/stand_back_square_0.png'
  'http://media.giphy.com/media/6fJaFCfOWYIW4/giphy.gif'
  'http://media.giphy.com/media/jHvnDjWx6bx6w/giphy.gif'
  'http://media.giphy.com/media/M7sBwHjMYhZra/giphy.gif'
  'http://media2.giphy.com/media/mv9sVnakzbtxS/giphy.gif'
  'http://media.giphy.com/media/o5FOLyP3sbWhO/giphy.gif'
  'http://media.giphy.com/media/12psn8ymXy3dYs/giphy.gif'
  'http://media.giphy.com/media/vVnLG6de2ud4A/giphy.gif'
  'http://media.giphy.com/media/8db6nRqMsLCtq/giphy.gif'
  'http://media.giphy.com/media/I1HQNWXZfpZ7i/giphy.gif'
]

nailedItGifs = [
  'http://i.minus.com/ibwcbATIPAHBFq.gif'
  'http://i.imgur.com/3LQ7eOn.gif'
  'http://www.reactiongifs.com/wp-content/uploads/2013/11/1318.gif'
  'http://www.reactiongifs.com/wp-content/uploads/2013/09/nailed-it.gif'
  'http://www.reactiongifs.com/wp-content/uploads/2013/04/yeah-nailed-it1.gif'
  'http://media.giphy.com/media/yTNXfyMid9v56/giphy.gif'
  'http://media.giphy.com/media/8VrtCswiLDNnO/giphy.gif'
  'http://media.giphy.com/media/T2EX8GTX0g4kU/giphy.gif'
  'http://media.giphy.com/media/10HgpkH8nyOv1m/giphy.gif'
  'http://media.giphy.com/media/urFfOfVApEJnG/giphy.gif'
  'http://i.imgur.com/O2PZvBZ.gif'
]

magicGifs = [
  'http://24.media.tumblr.com/a619d38de635a0702c91f3be14c76c0d/tumblr_mouqvxFNHG1sncj0to1_400.gif'
  'http://oi43.tinypic.com/20hsgpd.jpg'
  'http://img4.wikia.nocookie.net/__cb20120812041416/thefanfictionwikiofgtfandphazon/images/6/69/Clapping_Magic_.gif'
]

module.exports = (robot) ->
  # robot.hear /hodor/i, (msg) ->
  #   msg.send 'hodor'

  robot.hear /science/i, (msg) ->
    msg.send msg.random scienceGifs

  robot.hear /shaq/i, (msg) ->
    msg.send 'http://i.imgur.com/q3e87zR.gif'

  robot.hear /nailed\sit/i, (msg) ->
    msg.send msg.random nailedItGifs

  robot.hear /magic(?!bus)/i, (msg) ->
    msg.send msg.random magicGifs

  robot.hear /business/i, (msg) ->
    msg.send 'http://www.evilmilk.com/pictures/Haha_Business.jpg'

  robot.hear /booty/i, (msg) ->
    msg.send 'http://i.imgur.com/ecywERW.gif'

  robot.hear /mallocator/i, (msg) ->
    msg.send 'https://www.dropbox.com/s/gtew5itehui9yya/a898m.jpg'
