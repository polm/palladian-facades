raphael = require \raphael

WIDTH = 1280
PAPER = raphael 10, 20, WIDTH, 1000
UNIT = 40 # standard width unit
CENTER = WIDTH / 2

white = -> it.attr \fill, \white
black = -> it.attr \fill, \black

draw-triangle = (width, center, color=white) ->
  w2 = (UNIT * width) / 2
  w4 = ~~(w2 / 2)
  sx = center.x - w2
  sy = center.y
  color PAPER.path [
    "M#{center.x - w2} #sy L#{center.x} #{sy - w4}"
    "L#{center.x + w2} #sy z"
  ]

draw-roof-base = (width, center) ->
  # the "architrave" or "entablature", flat thing under pediment
  h = UNIT / 4
  cx = center.x - ( (width * UNIT) / 2)
  cy = center.y - h
  white PAPER.rect cx, cy, UNIT * width, h

draw-triangle-roof = (width, center) ->
  draw-roof-base width + 1, center
  center.y -= (UNIT / 4) # for the roof
  draw-triangle width + 1, center
  draw-triangle width, center

draw-flat-roof = (width, center) ->
  # trapezoid-shaped, dark
  lc = x: center.x - (width * UNIT / 2), y: center.y
  rc = x: center.x + (width * UNIT / 2), y: center.y
  draw-triangle 2, lc, black
  draw-triangle 2, rc, black
  h2 = UNIT / 2
  black PAPER.rect lc.x, lc.y - h2, width * UNIT, h2

draw-doorway = (center) ->
  cx = center.x
  cy = center.y + UNIT
  ww = UNIT / 2
  rect = PAPER.rect cx - (ww / 2), cy, ww, UNIT
  circle = PAPER.circle cx, cy, ww / 2
  rect.attr \fill, \black
  circle.attr \fill, \black

draw-doorway-section = (width, center) ->
  cx = center.x - (width * UNIT * 0.5) + (UNIT * 1.5)
  cy = center.y
  w2 = ~~(width / 2)
  for ii from 0 til w2
    draw-doorway x: cx, y: cy
    cx += 2 * UNIT

draw-windows = (width, center, condition) ->
  win = pick [draw-square-windows, draw-square-windows, draw-round-windows]
  win width, center, condition

draw-square-windows = (width, center, condition) ->
  ww = UNIT / 2
  wh = UNIT
  cx = center.x - ( (width * UNIT) / 2) + (ww / 2)
  cy = center.y + UNIT - (UNIT / 4)
  for ii from 0 til width
    if condition ii
      rect = PAPER.rect cx, cy, ww, wh
      rect.attr \fill, \black
    cx += UNIT

draw-round-windows = (width, center, condition) ->
  ww = UNIT / 2
  cx = center.x - ((width * UNIT) / 2) + (UNIT / 2)
  cy = center.y + (UNIT * 0.75)
  for ii from 0 til width
    if condition ii
      rect = PAPER.circle cx, cy, ww / 2
      rect.attr \fill, \black
    cx += UNIT

draw-all-windows = (width, center) ->
  draw-windows width, center, -> true

draw-even-windows = (width, center) ->
  draw-windows width, center, -> (it + 1)  % 2

draw-odd-windows = (width, center) ->
  draw-windows width, center, -> it % 2

draw-stairs = (width, center) ->
  h4 = UNIT / 4
  h8 = h4 / 2
  cx = center.x - (width * UNIT / 2) - h4
  cy = center.y
  for ii from 0 til 4
    PAPER.rect cx, cy + (ii * h8), (UNIT / 2) + (width * UNIT), h8

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
    white PAPER.rect cx, y, column-width, column-height
    cx = x - (cap-width / 2)
    white PAPER.rect cx, y, cap-width, cap-height
    cy = y + (UNIT * 2) - cap-height
    white PAPER.rect cx, cy, cap-width, cap-height
    x += UNIT # move over

draw-bannister = (width, center) ->
  # draw a porch railing
  uu = ~~(UNIT / 10)
  bh = UNIT / 4
  x = center.x - (UNIT * (width / 2))
  y = center.y + (2 * UNIT) - bh # this is the top
  for ii from 0 to width * 4
    cx = x - (uu / 2)
    white PAPER.rect cx, y, uu, bh
    x += UNIT / 4 # move over
  x = center.x - (UNIT * (width / 2))
  white PAPER.rect x, y - (uu / 2), width * UNIT, uu
  white PAPER.rect x, center.y + (UNIT * 2) - (uu / 2), width * UNIT, uu

draw-wall = (width, center, color) ->
  # just a wall without columns
  x = center.x - (UNIT * (width / 2))
  y = center.y # this is the top
  color PAPER.rect x, y, width * UNIT, 2 * UNIT

draw-plain-wall = (width, center) ->
  draw-wall width, center, white
draw-recessed-wall = (width, center) ->
  draw-wall width, center, -> it.attr \fill, \#ccc

draw-foundation = (width, center) ->
  # just a wall on the same level as the stairs
  x = center.x - (UNIT * (width / 2))
  y = center.y # this is the top
  white PAPER.rect x, y, width * UNIT, UNIT / 2

draw-building = (depth, width, floors, max-floor) -> # depth=0 front
  w = width
  h = 300 + ((UNIT * 2) * (max-floor - floors))
  cx = CENTER

  roof = pick [->, draw-flat-roof, draw-flat-roof, draw-triangle-roof ]
  roof w, x: cx, y: h
  for floor from 0 til floors
    if not R 3 then draw-recessed-wall w, x: cx, y: h
    else draw-plain-wall w, x: cx, y: h
    if R 2 then draw-column-section w, {x: cx, y: h}
    if floor == floors - 1 # bottom
      if depth == 1
        draw-doorway-section w, {x: cx, y: h}
    else
      win = pick [->, ->, draw-even-windows, draw-even-windows, draw-odd-windows, draw-odd-windows, draw-all-windows]
      win w, {x: cx, y: h}
      if not R 3 then draw-bannister w, x: cx, y: h
    h += UNIT * 2

  if depth == 1 then draw-stairs w, x: cx, y: h
  else draw-foundation w, x: cx, y: h

draw-stack = ->
  PAPER.clear!
  layers = []
  for ll from 0 til 2 + R 5
    fp = 1 + R 6
    wp = 1 + (2 * R 12)
    layers.push w: wp, f: fp

  max-floor = Math.max.apply null, layers.map -> it.f
  for li from 0 til layers.length
    layer = layers[li]
    draw-building layers.length - li, layer.w, layer.f, max-floor
  # maybe add a wall, if so maybe add towers


R = -> ~~(it * Math.random!)
pick = -> it[R it.length]
document.onclick = ->
  draw-stack!

draw-stack!
