extensions [ view2.5d ]

globals [
  observer-distance ; the observer's distance from its "focus point"
  observer-heading  ; the heading of the observer's angular perspective
  observer-pitch    ; the pitch of the the observer's angular perspective
  observer-x-focus  ; the x coordinate the observer is "looking at" in the patch plane
  observer-y-focus  ; the y coordinate the observer is "looking at" in the patch plane
  stem-thickness    ; the thickness of the "pins" or "stems" on which the turtles sit
  z-scale           ; factor for scaling the computed turtle height value
]

breed [ UAVs UAV ]
breed [ Commanders Commander ]
breed [ Civilians Civilian ]
breed [ Enemies Enemy ]
breed [ Putins Putin ]
breed [ Assets Asset ]

turtles-own [
  height      ; value of the reporter giving an agent's height (z-value; not scaled)
  stem-color  ; value of the reporter giving an agent's stem color
]

UAVs-own [
  kill_power
  perc_accuracy
  kill_accuracy
  has_target
  target
  pload
]

Commanders-own [
  attitude
  influence
  ability
  decision
  conviction
]

Civilians-own [
  damage
]

Enemies-own [
  damage
  threat
  destroyed
  evasion
]

Putins-own [
  damage
  destroyed
]

Assets-own [
  damage
  destroyed
]

to setup
  clear-all
  ;;random-seed 271828
  ask patches [ set pcolor green + random-normal 2 1 - random-normal 2 1 ]
  init-globals
  create-UAVs num-UAVs [
    set shape "airplane"
    move-to one-of patches
    ; initial heights are randomly distributed
    set height random-normal 2 .1
    set perc_accuracy random 100
    set Kill_accuracy random 100
    set stem-color blue set color blue set size 2
    set has_target 0
    set pload Payload
  ]

  create-Enemies num_Enemies [
    set destroyed 0
    move-to one-of patches ;;with [ pxcor < 22 and pycor > 22 ]
    set height 0.1
    set color red set stem-color color
    set shape "circle"
    set damage 0
    set evasion random 100
  ]

  create-Assets 1 [
    set destroyed 0
    set color blue
    set height 0
    set shape "box"
    move-to one-of patches with [ pxcor = 0 and pycor = 0 ]
    set size 5
  ]

  create-Putins 1 [
    set destroyed 0
    set color white
    set height random-normal 1 .3
    set shape "triangle"
    set size 2
    move-to one-of patches
  ]

  ask links [
    set color get-netlogo-color set thickness link-thickness
    ifelse show-links [ show-link ] [ hide-link ]
  ]

  reset-ticks
  create-turtle-view
end


to go
  ifelse show-links
    [ ask links [ set color get-netlogo-color set thickness link-thickness show-link ] ]
    [ ask links [ hide-link ] ]


  ask UAVs [
    if count enemies with [ destroyed = 0 ] > 0 and has_target = 0 [ set target one-of enemies with [ destroyed = 0 ]
      face target set has_target 1 set height 0.5 create-link-with target ]
    ;; move towards target.  once the distance is less than 1,
    ;; use move-to to land exactly on the target.
    if has_target = 1 [ face target ]
    if perc_Accuracy < random PAccuracy and kill_Accuracy < random KAccuracy and distance target < 1 and member? target enemies ;; and kill switch is on
    [ move-to target ask target [ set destroyed 1 fd 0 set color yellow set shape "star"] set has_target 0 ask my-links [ die ] set pload pload - 1]
    if count enemies with [ destroyed = 0 ] < 1 [ set heading heading + random 15 - random 15 fd speed set
      height 2 + random-normal 0.3 0.1 - random-normal 0.3 0.1 set has_target 0 ask my-links [ die ]  ]
    if [ destroyed ] of target = 1 and count enemies with [ destroyed = 0 ] > 1 [ set has_target 0 set target one-of enemies with [ destroyed = 0 ] ]
    fd random-float speed
    if pload = 0 [ die ]
]

  if count enemies > 1 [
    ask Enemies with [ color = red ]  [
    ; turtles move randomly
      rt random 90 lt random 90 fd Enemy_speed
      if any? UAVs-here with [ target = myself ] and evasion > random EAbility [ move-to one-of patches ]
      invade
  ]]
   ask one-of enemies [ hatch 1 fd 1 ]

  ;;wait .1
  ; changes in turtle view related variables only become visible when the view is updated
  view2.5d:update-turtle-view window-name turtles

  MakeNewEnemies

  tick
end

to invade
  ask one-of enemies [
    if not any? UAVs-on patch-here [ ask patch-here [ set pcolor black ]]
  ]
end


; change a string into the corresponding netlogo color
to-report get-netlogo-color
  let netlogo-color grey
  if link-color = "red"    [ set netlogo-color red ]
  if link-color = "blue"   [ set netlogo-color blue  ]
  if link-color = "green"  [ set netlogo-color green ]
  if link-color = "yellow" [ set netlogo-color yellow ]
  report netlogo-color
end

; One source for the window name
to-report window-name
  report "Turtle View"
end

; One could explore the effect of these variables by giving them each a slider
to init-globals
  set observer-distance 100
  set observer-x-focus 0
  set observer-y-focus 0
  set observer-heading 28
  set observer-pitch 56
  set z-scale 5
  set stem-thickness .2
end

to create-turtle-view
  ; Use anonymous functions to tie the turtle height and turtle
  ; stem color to variables that are manipulated elsewhere
  view2.5d:turtle-view window-name turtles [ the-turtle -> [height] of the-turtle ]
  view2.5d:set-turtle-stem-color window-name [ the-turtle -> [stem-color] of the-turtle ]
  wait 1

  set-z-scale
  set-observer-distance
  set-observer-xy-focus
  set-observer-angles
  set-stem-thickness
  view2.5d:update-turtle-view window-name turtles
end

to set-observer-distance
  view2.5d:set-observer-distance window-name observer-distance
end

to set-observer-xy-focus
  view2.5d:set-observer-xy-focus window-name observer-x-focus observer-y-focus
end

to set-observer-angles
  view2.5d:set-observer-angles window-name observer-heading  observer-pitch
end

to set-z-scale
  view2.5d:set-z-scale window-name z-scale
end

to set-stem-thickness
  view2.5d:set-turtle-stem-thickness window-name stem-thickness
end

to MakeNewEnemies
  if mouse-down? = true [
    create-enemies 5 [
    set destroyed 0
    set height 0.1
    set color red set stem-color color
    set shape "square"
    setxy mouse-xcor mouse-ycor
    face one-of Assets  ]
  ]
end



; Public Domain:
; To the extent possible under law, Uri Wilensky has waived all
; copyright and related or neighboring rights to this model.
@#$#@#$#@
GRAPHICS-WINDOW
220
10
766
557
-1
-1
10.55
1
10
1
1
1
0
1
1
1
-25
25
-25
25
1
1
1
ticks
30.0

BUTTON
10
10
76
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
395
192
428
link-thickness
link-thickness
0
5
0.1
.1
1
NIL
HORIZONTAL

SWITCH
15
290
140
323
show-links
show-links
0
1
-1000

CHOOSER
15
335
153
380
link-color
link-color
"red" "green" "blue" "yellow"
0

BUTTON
10
55
105
88
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
20
140
192
173
num-UAVs
num-UAVs
1
100
100.0
1
1
NIL
HORIZONTAL

MONITOR
795
70
968
115
Max Scaled Turtle Height
max [ height ] of turtles * z-scale
2
1
11

MONITOR
795
117
968
162
Min Scaled Turtle Height
min [ height ] of turtles * z-scale
2
1
11

MONITOR
795
163
967
208
Mean Scaled Turtle Height
mean [ height ] of turtles * z-scale
2
1
11

SLIDER
20
105
192
138
num_Enemies
num_Enemies
0
100
39.0
1
1
NIL
HORIZONTAL

MONITOR
85
175
172
220
Enemy Forces
count enemies with [ color = red ]
0
1
11

SLIDER
795
209
968
242
Speed
Speed
0
2
1.27
.01
1
NIL
HORIZONTAL

SLIDER
795
245
967
278
Enemy_Speed
Enemy_Speed
0
1
0.01
0.01
1
NIL
HORIZONTAL

MONITOR
19
438
121
483
Destroyed Area
count patches with [ pcolor = black ] / count patches * 100
1
1
11

SLIDER
795
289
967
322
KAccuracy
KAccuracy
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
795
330
967
363
PAccuracy
PAccuracy
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
795
370
967
403
EAbility
EAbility
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
795
405
967
438
Payload
Payload
0
100
5.0
1
1
NIL
HORIZONTAL

MONITOR
20
175
77
220
UAVs
count UAVs
0
1
11

@#$#@#$#@
## WHAT IS IT?

This example demonstrates the use of the `view2.5d` extension for turtle views. The `view2.5d` extension allows properties of turtles to be visualized using their height and stem color.

This example also shows how links between turtles can be visualized in three dimensions.

The model opens a separate "Turtle View" window by calling:

```
  view2.5d:turtle-view window-name turtles [ the-turtle -> [height] of the-turtle ]
```

The anonymous reporter supplied to the `view2.5d:turtle-view` primitive is used by the extension to set the height of each turtle.

The anonymous reporter supplied to the `view2.5d:set-turtle-stem-color` primitive is used by the extension to set the stem color of each turtle.

The method `view2.5d:set-turtle-stem-thickness` is used to set the stem color of each turtle.

In the `go` procedure, we use `view2.5d:update-turtle-view` to refresh the turtle view using the current state of the model.

Several extension-specific methods are used to control the three dimensional visualization of this "Turtle View":

- `view2.5d:set-observer-distance` sets the observer's distance from its "focus point."

- `view2.5d:set-observer-heading` sets the heading of the observer's angular perspective.

- `view2.5d:set-observer-pitch` sets the pitch of the the observer's angular perspective.

- `view2.5d:set-observer-x-focus` sets the x coordinate the observer is "looking at" in the patch plane.

- `view2.5d:set-observer-y-focus` sets the y coordinate the observer is "looking at" in the patch plane.

- `view2.5d:set-z-scale` sets the scale of the z-axis, in this case making the turtles "taller".

For more information, please refer to the `view2.5d` extension documentation.

## HOW IT WORKS

At each tick the height and turtle stem color are changed based on properties of the turtles within a small radius.

The height is changed by the difference between a turtle's height and the average height of its near neighbors (if any). That means if a turtle is at a lower height than the average of its neighbors, its height will increase, and if a turtle's height is higher than the average of its neighbors, its height will decrease.

The stem color is changed to the average stem color of its near neighbors (if any).

The turtle takes on the color of its stem.

## HOW TO USE IT

The model has standard SETUP and GO buttons.

The NUM-TURTLES slider determines the initial number of turtles.

The link related interface items take effect at the next tick.

The links are visible when the SHOW-LINKS? switch is set to ON, and invisible if it is set to OFF.

There is a chooser to chose the LINK-COLOR.

A slider is used to set the LINK-THICKNESS. Note that the thickness appears much larger in the small 2D inset.

## THINGS TO TRY

Use the NUM-TURTLES slider to explore how increasing or decreasing the number of turtles affects how quickly the height and stem color of the turtles changes.

Use the switch, chooser, or slider to instantaneously change the visualization of links.

In the 3D window, explore the effect of the different View Options by selecting different combinations of check boxes and switching between Link Options by using radio buttons.

Note that links are shown using the 3D option by default. To programmatically start a model with links shown in 2D, add the following line

```
  view2.5d:show-links-xy-plane  window-name
```
after the line with the `view2.5d:turtle-view` command.

## RELATED MODELS

- 2.5d Patch View Example

<!-- 2020 -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
need-to-manually-make-preview-for-this-model
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
