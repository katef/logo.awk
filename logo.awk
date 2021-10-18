#!/usr/bin/awk -f

# run like: cat examples/house.logo | awk -f logo.awk

BEGIN {
	pi = atan2(0, -1)
	x = 0.0
	y = 0.0
	angle = -90

	print "<?xml version='1.0' encoding='UTF-8' standalone='no'?>"
	print ""

	print "<svg"
	print "   xmlns='http://www.w3.org/2000/svg'"
	print "   width='80mm'"
	print "   height='80mm'"
	print "   viewBox='-20 -40 50 50'"
	print "   version='1.1'>"
	print ""

	print "  <style>path { fill: none; stroke: white; stroke-width: 1; stroke-linecap: butt; }</style>"
	print "  <style>path.turtle { fill: none; stroke: red; stroke-width: 0.8; }</style>"
	print ""

	pendown()
}

END {
	print "'/>"
	printf "  <g transform='translate(%d,%d) rotate(%d)'>\n", x, y, angle
	print "    <path class='turtle' d='M.2,0 L-6,2 -4,0 -6,-2 Z'/>"
	print "  </g>"
	print "</svg>"
}

function move(n,   r) {
	r = angle * (pi / 180)
	x += n * cos(r)
	y += n * sin(r)

	printf " L%d,%d", x, y
}

function turn(n) {
	angle += n
	angle %= 360
}

function penup() {
	print "'/>"
}

function pendown() {
	printf "  <path d='M%d,%d", x, y
}

/^FD/ { move(+$2); }
/^BK/ { move(-$2); }
/^RT/ { turn(+$2); }
/^LT/ { turn(-$2); }
/^PU/ { penup();   }
/^PD/ { pendown(); }

