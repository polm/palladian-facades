raphael = require \raphael

PAPER = raphael 10 20 640 320
UNIT = 40 # standard width unit

draw-triangle = (width, center) ->
  w2 = (UNIT * width) / 2
  w4 = ~~(w2 / 2)
  sx = center.x - w2
  sy = center.y
  PAPER.path [
    "M#{center.x - w2} #sy L#{center.x} #{sy - w4}"
    "L#{center.x + w2} #sy z"
  ]

draw-roof-base = (width, center) ->
  # the "architrave" or "entablature", flat thing under pediment
  h = UNIT / 4
  cx = center.x - ( (width * UNIT) / 2)
  cy = center.y - h
  PAPER.rect cx, cy, UNIT * width, h

draw-triangle-roof = (width, center) ->
  draw-roof-base width + 1, center
  center.y -= (UNIT / 4) # for the roof
  draw-triangle width + 1, center
  draw-triangle width, center

draw-windows = (width, center) ->
  ww = UNIT / 2
  wh = UNIT
  cx = center.x - ( (width * UNIT) / 2) + (ww / 2)
  cy = center.y + UNIT - (UNIT / 4)
  for ii from 0 til width
    rect = PAPER.rect cx, cy, ww, wh
    rect.attr \fill, \black
    cx += UNIT

draw-column-section = (width, center) ->
  # draw width+1 columns, each 2 UNIT high
  column-width = ~~(UNIT / 8)
  column-height = 2 * UNIT
  cap-width = ~~(UNIT / 4)
  cap-height = ~~(UNIT / 10)

  # figure out where to start
  x = center.x - (UNIT * (width / 2))
  y = center.y # this is the top

  for ii from 0 to width
    cx = x - (column-width / 2)
    PAPER.rect cx, y, column-width, column-height
    cx = x - (cap-width / 2)
    PAPER.rect cx, y, cap-width, cap-height
    cy = y + (UNIT * 2) - cap-height
    PAPER.rect cx, cy, cap-width, cap-height
    x += UNIT # move over

R = -> ~~(it * Math.random!)
document.onkeydown = ->
  if it.which = 13
    w = 3 + R 6
    PAPER.clear!
    draw-triangle-roof w, {x: 320, y: 100}
    draw-column-section w, {x: 320, y: 100}
    draw-windows w, {x: 320, y: 100}
    draw-column-section w, {x: 320, y: 180}
