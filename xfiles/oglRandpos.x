#
#	oglRandpos.x
#
#	noise stimulus that varies spatial position of a bar
#	ogl version of vrandpos
#

foo nonperiodic	11

#

0	dur		"Stimulus duration (s *10)"		20	1-1800 1+
1	c		"Contrast (%)"				50	0-100 1+
2	barlgth		"Bar length (deg *10)"			200	1-800 1+
3	barwdth		"Bar Width (deg *10)"			40	1-400 1+
4	sf		"Spatial Frequency (cpd * 100)"		20	1-2000 1+
5	nori		"Number of orientations"		20	1-30 1+
6	npos		"Number of positions"			8	1-30 1+
7	nphase		"Number of spatial phases"		2	1-20 1+
8	seed		"Random seed"				1	1-800 1+
9	nfr		"Number of frames"			1	1-30  1+
10	bprob		"Percent Blank Frames"			10	1-100  1+
