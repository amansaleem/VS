#
#	flickDrift.x
#
#
#       071022 LB

foo periodic	8

#

0	dur		"Stimulus duration (s *10)"			20	1-1200 1+
1	tf		"Temporal frequency drift (Hz *100)"	400	1-4000 1+
2	sf		"Spatial frequency (cpd *100)"		15	1-2000 1+
3	c		"Contrast (%)"					100	0-100 1+
4	ori		"Orientation (deg *10)"		      	  0	0-3600 1+
5	durOn		"Stimulus on duration (s *10)"	       3	1-500 1+
6	durOff	"Stimulus off duration (s *10)"	       3	0-500 1+
7	endBlank	"Duration of blank at end (s*10)"	       0	0-500 1+
