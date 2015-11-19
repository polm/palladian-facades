raphael = require \raphael

UNIT = 40 # standard width unit
U2 = UNIT / 2
U4 = UNIT / 4
U8 = UNIT / 8

SCALE = 1
WIDTH = window.inner-width * SCALE
HEIGHT = window.inner-height * SCALE
MAX_FLOORS = ~~(HEIGHT / (2 * UNIT)) - 2
MAX_WIDTH = ~~(WIDTH / (2 * UNIT)) - 2
PAPER = raphael 10, 50, WIDTH / SCALE, HEIGHT / SCALE
CENTER = WIDTH / 2

white = -> it.attr \fill, \white
black = -> it.attr \fill, \black

draw-triangle = (width, center, color=white) ->
  w2 = U2 * width
  w4 = ~~(w2 / 2)
  sx = center.x - w2
  sy = center.y
  color PAPER.path [
    "M#{center.x - w2} #sy L#{center.x} #{sy - w4}"
    "L#{center.x + w2} #sy z"
  ]

draw-roof-base = (width, center) ->
  # the "architrave" or "entablature", flat thing under pediment
  cx = center.x - ( (width * UNIT) / 2)
  cy = center.y - U4
  white PAPER.rect cx, cy, UNIT * width, U4

draw-triangle-roof = (width, center) ->
  draw-roof-base width + 1, center
  center.y -= (UNIT / 4) # for the roof
  draw-triangle width + 1, center
  draw-triangle width, center

draw-flat-roof = (width, center) ->
  # trapezoid-shaped, dark
  lc = x: center.x - (width * U2), y: center.y
  rc = x: center.x + (width * U2), y: center.y
  draw-triangle 2, lc, black
  draw-triangle 2, rc, black
  black PAPER.rect lc.x, lc.y - U2, width * UNIT, U2

draw-doorway = (center) ->
  cx = center.x
  cy = center.y + UNIT
  rect = PAPER.rect cx - (U2 / 2), cy, U2, UNIT
  circle = PAPER.circle cx, cy, U2 / 2
  rect.attr \fill, \black
  circle.attr \fill, \black

draw-doorway-section = (width, center) ->
  cx = center.x - (width * U2) + UNIT + U2
  cy = center.y
  w2 = ~~(width / 2)
  for ii from 0 til w2
    draw-doorway x: cx, y: cy
    cx += 2 * UNIT

draw-windows = (width, center, condition) ->
  win = pick [draw-square-windows, draw-square-windows, draw-round-windows]
  win width, center, condition

draw-square-windows = (width, center, condition) ->
  cx = center.x - (width * U2) + U4
  cy = center.y + UNIT - U4
  for ii from 0 til width
    if condition ii
      rect = PAPER.rect cx, cy, U2, UNIT
      rect.attr \fill, \black
    cx += UNIT

draw-round-windows = (width, center, condition) ->
  cx = center.x - (width * U2) + U2
  cy = center.y + U2 + U4
  for ii from 0 til width
    if condition ii
      rect = PAPER.circle cx, cy, U4
      rect.attr \fill, \black
    cx += UNIT

draw-all-windows = (width, center) ->
  draw-windows width, center, -> true

draw-even-windows = (width, center) ->
  draw-windows width, center, -> (it + 1)  % 2

draw-odd-windows = (width, center) ->
  draw-windows width, center, -> it % 2

draw-stairs = (width, center) ->
  cx = center.x - (width * UNIT / 2) - U4
  cy = center.y
  for ii from 0 til 4
    PAPER.rect cx, cy + (ii * U8), U2 + (width * UNIT), U8

draw-column-section = (width, center) ->
  # draw width+1 columns, each 2 UNIT high
  column-width = U8
  column-height = 2 * UNIT
  cap-width = U4
  cap-height = ~~(UNIT / 10)

  # figure out where to start
  x = center.x - (UNIT * (width / 2))
  y = center.y # this is the top

  for ii from 0 to width
    cx = x - (U8 / 2)
    white PAPER.rect cx, y, column-width, column-height
    cx = x - (cap-width / 2)
    white PAPER.rect cx, y, cap-width, cap-height
    cy = y + (UNIT * 2) - cap-height
    white PAPER.rect cx, cy, cap-width, cap-height
    x += UNIT # move over

draw-bannister = (width, center) ->
  # draw a porch railing
  uu = ~~(UNIT / 10)
  x = center.x - (width * U2)
  y = center.y + (2 * UNIT) - U4 # this is the top
  for ii from 0 to width * 4
    cx = x - (uu / 2)
    white PAPER.rect cx, y, uu, U4
    x += U4 # move over
  x = center.x - (width * U2)
  white PAPER.rect x, y - (uu / 2), width * UNIT, uu
  white PAPER.rect x, center.y + (UNIT * 2) - (uu / 2), width * UNIT, uu

draw-wall = (width, center, color) ->
  # just a wall without columns
  x = center.x - (width * U2)
  y = center.y # this is the top
  color PAPER.rect x, y, width * UNIT, 2 * UNIT

draw-plain-wall = (width, center) ->
  draw-wall width, center, white
draw-recessed-wall = (width, center) ->
  draw-wall width, center, -> it.attr \fill, \#ccc

draw-foundation = (width, center) ->
  # just a wall on the same level as the stairs
  x = center.x - (width * U2)
  y = center.y # this is the top
  white PAPER.rect x, y, width * UNIT, U2

draw-building = (depth, width, floors, center=CENTER) -> # depth=0 front
  w = width
  h = ((UNIT * 2) * (1 + MAX_FLOORS - floors))
  cx = center

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

draw-stack = (max-width=12, max-floors=6, center=CENTER) ->
  layers = []
  for ll from 0 til 2 + R 4
    fp = 1 + R max-floors
    wp = 1 + (2 * R max-width)
    layers.push w: wp, f: fp

  for li from 0 til layers.length
    layer = layers[li]
    draw-building layers.length - li, layer.w, layer.f, center
  # maybe add a wall, if so maybe add towers

draw-tower = (center=CENTER) ->
  draw-stack 3, 7, center

draw-base = (center=CENTER) ->
  draw-stack 20, 3, center

draw-fit = (center=CENTER) ->
  narrow = ~~(MAX_WIDTH / 4)
  narrowish = ~~(MAX_WIDTH / 2) - 1
  short = ~~(MAX_FLOORS / 2)
  draw-stack MAX_WIDTH, short
  draw-stack narrow, MAX_FLOORS
  draw-stack narrow, MAX_FLOORS, center - (U2 * MAX_WIDTH) - R narrowish
  draw-stack narrow, MAX_FLOORS, center + (U2 * MAX_WIDTH) + R narrowish

draw-three-towers = ->
  draw-base CENTER
  draw-tower CENTER
  draw-tower CENTER - (10 * UNIT)
  draw-tower CENTER + (10 * UNIT)

ready-download = ->
  link = document.query-selector \#download
  link.hreflang = \image/svg+xml
  link.href = "data:image/svg+xml;utf8," + unescape document.query-selector(\svg).outerHTML
  link.download = \palladio.svg

get-all-bounds = ->
  set = PAPER.set!
  PAPER.for-each -> set.push it
  return set.getBBox!

size-to-fit = ->
  PAPER.set-view-box 0, 0, WIDTH, HEIGHT

R = -> ~~(it * Math.random!)
pick = -> it[R it.length]

do-all = ->
  PAPER.clear!
  draw-fit!
  size-to-fit!
  ready-download!

recalculate-size = (scale=1) ->
  WIDTH := window.inner-width * scale
  HEIGHT := window.inner-height * scale
  MAX_FLOORS := ~~(HEIGHT / (2 * UNIT)) - 2
  MAX_WIDTH := ~~(WIDTH / (2 * UNIT)) - 2
  CENTER := WIDTH / 2
  PAPER.clear!
  document.query-selector(\svg).remove!
  PAPER := raphael 10, 50, WIDTH / scale, HEIGHT / scale
  document.query-selector(\svg).onclick = do-all

window.onresize = ->
  recalculate-size!
  do-all!

document.query-selector(\#loop).onclick = ->
  it.preventDefault!
  set-interval do-all, 10 * 1000

document.query-selector(\svg).onclick = do-all
do-all!
window.PAPER = PAPER
