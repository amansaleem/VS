#
#	oglFlickeringChecks.x
#

foo periodic	7

#

0	dur		"Duration (s *10)"			20	10-100 1+
1	tf		"Temporal frequency flicker (Hz *10)"	10	1-160 1+
2	c		"Contrast (%)"				100	0-100 1+
3	size		"CheckSize (deg *10)"			145	5-500 10+
4	width		"width (deg *10)"			580	5-900 5+
5	ctr		"center (deg *10)"			0	-800-1000 1+
6	sqwv		"Sine (0) or Square (1)"		1	0-1 1+