#
#	oglOneGrating_IC1013.x
#
#	1 grating in 1 window.
#

foo periodic	15

#

0	dur		"Stimulus duration (s *10)"		20	1-600 1+
1	tf1		"Patch 1: Temporal frequency (Hz *10)"	40	1-400 1+
2	sf1		"Patch 1: Spatial frequency (cpd *100)"	10	1-200 1+
3 	tph1		"Patch 1: Temporal phase (deg)"		0	0-360 1+
4 	sph1		"Patch 1: Spatial phase (deg)"		0	0-360 1+
5	c1		"Patch 1: Contrast (%)"			50	0-100 1+
6	ori1		"Patch 1: Orientation (deg)"		90	0-360 1+
7 	dima1		"Patch 1: Inner Diam or Size X (deg *10)"	30	0-1199 1+
8	dimb1		"Patch 1: Outer Diam or Size Y (deg *10)"	100	1-1200 1+
9	x1		"Patch 1: Center, x (deg *10)"		0	-1000-1000 1+
10	y1		"Patch 1: Center, y (deg *10)"		0	-500-500 1+
11	flick1 		"Patch 1: Drift (0) or Flicker (1)"	0	0-1 1+
12	sqwv1		"Patch 1: Sine (0) or Square (1)"	0	0-1 1+
13	duty1 		"Patch 1: Duty cycle (%)"		100	1-100 1+
14	shape1 		"Patch 1: Annulus (0) or Rectangle (1)"	0	0-1 1+
