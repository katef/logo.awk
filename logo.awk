#!/usr/bin/awk -f

# run like: cat examples/house.logo | awk -f logo.awk

BEGIN {
	pi = atan2(0, -1)
	res = 10
	N = 0

	print "<?xml version='1.0' encoding='UTF-8' standalone='no'?>"
	print ""

	print "<svg"
	print "   xmlns='http://www.w3.org/2000/svg'"
	print "   width='80mm'"
	print "   height='80mm'"
	print "   viewBox='-200 -400 500 500'"
	print "   version='1.1'>"
	print ""

	print "  <style>path { fill: none; stroke: white; stroke-width: 10; stroke-linecap: square; }</style>"
	print "  <style>path.turtle { fill: none; stroke: red; stroke-width: 8; stroke-linejoin: round; }</style>"
	print ""

	home()
	pendown()
}

END {
	print "'/>"
	printf "  <g transform='translate(%d,%d) rotate(%d)'>\n", x * res, y * res, angle
	print "    <path class='turtle' d='M2,0 L-60,20 -40,0 -60,-20 Z'/>"
	print "  </g>"
	print "</svg>"
}

function move(n,   r) {
	r = angle * (pi / 180)
	x += n * cos(r)
	y += n * sin(r)

	printf " L%d,%d", x * res, y * res
}

function turn(n) {
	angle += n
	angle %= 360
}

function penup() {
	print "'/>"
}

function pendown() {
	printf "  <path d='M%d,%d", x * res, y * res
}

function home() {
	x = 0
	y = 0
	angle = -90
}

function repeat(n) {
	N = n
	cmds = ""
}

function endrepeat() {
	l = split(cmds, cmdarray, "\n")
	for (i = 1; i<=N; i++) {
		for (j = 1; j<=l; j++) {
			act(cmdarray[j], 0);
		}
	}
	N = 0
}

function act(input, repeating) {
split(input, parse)
switch (input) {
	case /^FD/:
		(!repeating) ? move(+parse[2]) : cmds = cmds "\n" $0
		break
	case /^BK/:
		(!repeating) ? move(-parse[2]) : cmds = cmds "\n" $0
		break
	case /^RT/:
		(!repeating) ? turn(+parse[2]) : cmds = cmds "\n" $0
		break
	case /^LT/:
		(!repeating) ? turn(-parse[2]) : cmds = cmds "\n" $0
		break
	case /^PU/:
		(!repeating) ? penup() : cmds = cmds "\n" $0
		break
	case /^PD/:
		 pen(!repeating) ? down() : cmds = cmds "\n" $0
		break
	case /^HOME/:
		(!repeating) ? home() : cmds = cmds "\n" $0
		break
	case /^\]/:
		endrepeat()
		break
	case /^REPEAT\W+[0-9]*\W*\[/:
		repeat(+$2)
		break
}
}

{ act($0, 1) }

