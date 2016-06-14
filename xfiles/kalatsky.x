#
#	oglKalatsky.x
#
#	adapted from Kalatsky & Stryker, Neuron, 2003
#
#       070505 LB changed 	tf (Hz*100 -> Hz*1000)
#				sf (cpd*100 -> cpd*1000)

foo periodic	7

#

0	dur		"Stimulus duration (s *10)"		10	1-1200 1+
1	tf		"Temporal frequency drift (Hz *1000)"	120	1-4000 1+
2	sf		"Spatial frequency (cpd *1000)"		30	1-2000 1+
3	c		"Contrast (%)"				100	0-100 1+
4	ori		"Orientation (deg)"		        90	0-360 1+
5 	flickerfreq	"Frequency of flicker (Hz *10)"		30	0-800 1+
6	duty 		"Duty cycle (%)"			10	1-100 1+
