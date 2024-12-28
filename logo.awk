#!/usr/bin/awk -f

# run like: cat examples/house.logo | awk -f logo.awk

BEGIN {
	pi = atan2(0, -1)
	pen = 0
	glow = 8
	pad = glow * 2

	# the world is 50 units up, 80 right & left, and 30 down
	res = 10
	above = 5 * res
	below = 3 * res
	height = above + below
	width = height * 2

	print "<?xml version='1.0' encoding='UTF-8' standalone='no'?>"
	print ""

	print "<svg"
	print "   xmlns='http://www.w3.org/2000/svg'"
	printf "   viewBox='%d %d %d %d'\n",
		-width * res / 2 - pad,
		-above * res - pad,
		width * res + 2 * pad,
		height * res + 2 * pad
	print "   version='1.1'>"
	print ""

	print "  <style>* { fill: none; stroke: white; stroke-linecap: round; stroke-linejoin: round; }</style>"
	print "  <style>path { stroke-width: 10; stroke-linecap: square; }</style>"
	print "  <style>path.turtle { stroke: red; }</style>"
	print "  <style>path.pen1 { stroke-width: 8; stroke-opacity: 1; }</style>"
	print "  <style>path.pen0 { stroke-width: 8; stroke-opacity: 0.3; }</style>"
	print "  <style>line.major { stroke-width: 1; opacity: 0.8; }</style>"
	print "  <style>line.minor { stroke-width: 0.8; opacity: 0.1; }</style>"
	print ""

	# https://stackoverflow.com/questions/9630008/how-can-i-create-a-glow-around-a-rectangle-with-svg
	print "  <filter id='glow' width='2' height='2' x='-0.5' y='-0.5'>"
	printf "    <feGaussianBlur stdDeviation='%d' result='coloredBlur'/>\n", glow
	print "    <feMerge>"
	print "      <feMergeNode in='coloredBlur'/>"
	print "      <feMergeNode in='SourceGraphic'/>"
	print "    </feMerge>"
	print "  </filter>"
	print ""

	grid()

	# When applying #glow directly to <path> (either by CSS or by an attribute),
	# paths that are exactly vertical or horizontal disappear. Presumably the glow
	# (mistakenly?) treats them as zero dimension, despite having a stroke-width set.
	# My solution is to apply the filter to a containing <g> instead.
	print "  <g style='filter: url(#glow);'>"
	home()
}

END {
	print "'/>"
	printf "    <g transform='translate(%d,%d) rotate(%d)'>\n", x * res, y * res, angle
	printf "      <path class='turtle pen%d' d='M2,0 L-60,20 -40,0 -60,-20 Z'/>\n", pen
	print "    </g>"

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
		printf "    <path d='M%d,%d", x * res, y * res
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

function grid() {
	for (i = -width; i <= width; i++) {
		printf "<line class='%s' x1='%d' y1='%d' x2='%d' y2='%d'/>\n",
			i % res ? "minor" : "major",
			i * res, -height * res,
			i * res,  height * res
	}
	for (j = -height; j <= height; j++) {
		printf "<line class='%s' x1='%d' y1='%d' x2='%d' y2='%d'/>\n",
			j % res ? "minor" : "major",
			-width * res, j * res,
			 width * res, j * res
	}
}

/^FD/   { move(+$2) }
/^BK/   { move(-$2) }
/^RT/   { turn(+$2) }
/^LT/   { turn(-$2) }
/^PU/   { penup()   }
/^PD/   { pendown() }
/^HOME/ { home()    }

