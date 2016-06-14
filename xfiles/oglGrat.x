#
#	oglGrat.x
#       x file for one grating

foo periodic	15

#

0	dur		"Stimulus duration (s *10)"		10	1-600 1+
1	tf		"Patch 1: Temporal frequency (Hz *10)"	40	1-400 1+
2	sf		"Patch 1: Spatial frequency (cpd *100)"	10	1-200 1+
3 	tph		"Patch 1: Temporal phase (deg)"		0	0-360 1+
4 	sph		"Patch 1: Spatial phase (deg)"		0	0-360 1+
5	c1		"Patch 1: Contrast (%)"			50	0-100 1+
6	ori		"Patch 1: Orientation (deg)"		90	0-360 1+
7 	dima		"Patch 1: Inner Diam or Size X (deg *10)"	0	0-800 1+
8	dimb		"Patch 1: Outer Diam or Size Y (deg *10)"	100	1-800 1+
9	x		"Patch 1: Center, x (deg *10)"		0	-500-500 1+
10	y		"Patch 1: Center, y (deg *10)"		0	-500-500 1+
11	flick 		"Patch 1: Drift (0) or Flicker (1)"	0	0-1 1+
12	sqwv		"Patch 1: Sine (0) or Square (1)"	0	0-1 1+
13	duty 		"Patch 1: Duty cycle (%)"		100	1-100 1+
14	shape 		"Patch 1: Annulus (0) or Rectangle (1)"	0	0-1 1+


