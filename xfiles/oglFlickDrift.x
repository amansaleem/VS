#
#	oglFlickDrift.x
#
#
#       071022 LB
#       080222 LB

foo periodic	8

#

0	dur		"Stimulus duration (s *10)"			10	1-1200 1+
1	tf		"Temporal frequency drift (Hz *10)"	40	1-400 1+
2	sf		"Spatial frequency (cpd *100)"		15	1-2000 1+
3	c		"Contrast (%)"					20	0-100 1+
4	ori		"Orientation (deg)"		      	  0	0-360 1+
5	durOn		"Stimulus on duration (s *10)"	       3	1-500 1+
6	durOff	"Stimulus off duration (s *10)"	       2	0-500 1+
7	endBlank	"Duration of blank at end (s*10)"	       0	0-500 1+
