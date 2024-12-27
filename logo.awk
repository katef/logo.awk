#!/usr/bin/awk -f

# run like: cat examples/house.logo | awk -f logo.awk

BEGIN {
	pi = atan2(0, -1)
	res = 10
	pen = 0

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
	print "  <style>path.turtle { fill: none; stroke: red; stroke-linejoin: round; }</style>"
	print "  <style>path.pen1 { stroke-width: 8; stroke-opacity: 1; }</style>"
	print "  <style>path.pen0 { stroke-width: 8; stroke-opacity: 0.3; }</style>"
	print ""

	home()
}

END {
	print "'/>"
	printf "  <g transform='translate(%d,%d) rotate(%d)'>\n", x * res, y * res, angle
	printf "    <path class='turtle pen%d' d='M2,0 L-60,20 -40,0 -60,-20 Z'/>\n", pen
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
	if (pen == 1) {
		print "'/>"
		pen = 0
	}
}

function pendown() {
	if (pen == 0) {
		printf "  <path d='M%d,%d", x * res, y * res
		pen = 1
	}
}

function home() {
	penup()

	x = 0
	y = 0
	angle = -90

	pendown()
}

/^FD/   { move(+$2); }
/^BK/   { move(-$2); }
/^RT/   { turn(+$2); }
/^LT/   { turn(-$2); }
/^PU/   { penup();   }
/^PD/   { pendown(); }
/^HOME/ { home();    }

