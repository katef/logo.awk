#!/usr/bin/awk -f

# run like: cat examples/house.logo | awk -f logo.awk

BEGIN {
	pi = atan2(0, -1)
	res = 10
	N = 0
	d = 0
	split("", cmdarray)

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
	d += 1
	cmds[d] = n
}

function endrepeat(depth) {
	# Seemingly this idiom with tmp and then writing into cmdarray is required
	# and you can't split into a multidimensional array
	cmd_len[depth] = split(cmds[depth], tmp, "\n")
	for (key in tmp) {
		cmdarray[depth,key] = tmp[key]
	}
	for (i = 1; i<=(+cmdarray[depth, 1]); i++) {
		for (j = 1; j<=cmd_len[depth]; j++) {
			act(cmdarray[depth,j], depth-1);
		}
	}
	d-=1
}

function act(input, depth) {
	if (depth) {
		if (input ~ /^\]/):
			endrepeat(depth)
		else
			cmds[depth] = cmds[depth] "\n" input
		return
	}

	l=split(input, parse)
	switch (input) {
		case /^FD/:
			move(+parse[2])
			break
		case /^BK/:
			move(-parse[2])
			break
		case /^RT/:
			turn(+parse[2])
			break
		case /^LT/:
			turn(-parse[2])
			break
		case /^PU/:
			penup()
			break
		case /^PD/:
			down()
			break
		case /^HOME/:
			home()
			break
	}
}

/^REPEAT\W+[0-9]*\W*\[/ { repeat(+$2) }
{ act($0, d) }

