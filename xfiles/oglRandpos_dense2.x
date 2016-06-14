#
#	oglRandpos_dense2.x
#
#	noise stimulus that varies the position of a bar
#	random phase assignment.
#	blanks in stimulus.
#	density parameter but no overlap parameter and no adapter.
#	can limit width and specify center of array (x-dimension)
#

foo nonperiodic	10

#

0	dur		"Stimulus duration (s *10)"		20	1-1800 1+
1	c		"Contrast (%)"				75	0-100 1+
2	width		"Width of bars (deg *10)"		40	1-200 1+
3	density		"Density of stimuli (%)"		0	0-100 1+
4	baseori		"Base orientation of stimuli (deg)"	0	0-179 1+
5	seed		"Seed for random number generator"	1	1-32700 1+
6	nfr		"Number of interpolated frames"		1	1-30 1+
7	bprob		"Blank probability (%)"			0   	0-100 1+
8	arraywidth	"Width of stimulus array (deg*10)"	500	20-1000 1+
9	array_ctr	"Array offset from screen ctr (deg*10)"	0	-800-800 1+
