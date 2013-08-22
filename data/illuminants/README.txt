Illuminants_SimonFraser is a Matlab data file (31x102) with 102 difference scene illuminants. 

I combined the data from two sets of published data:
see : http://www.cs.sfu.ca/~colour/data/colour_constancy_synthetic_test_data/


I got the first data set from : 
http://www.cs.sfu.ca/~colour/data/colour_constancy_synthetic_test_data/image_data_sources.illum.gz

	"The illuminant sources were: 

	Sylvania 50MR16Q (12VDC)---A basic tungsten bulb
	Sylvania 50MR16Q (12VDC) + Roscolux 3202 Full Blue filter
	Solux 3500K (12VDC)--Emulation of daylight
	Solux 3500K (12VDC)+Roscolux 3202---Emulation of daylight
	Solux 4100K (12VDC)--Emulation of daylight
	Solux 4100K (12VDC)+Roscolux 3202---Emulation of daylight
	Solux 4700K (12VDC)--Emulation of daylight
	Solux 4700K (12VDC)+Roscolux 3202---Emulation of daylight
 	Sylvania Warm White Fluorescent (110VAC)
	Sylvania Cool White Fluorescent (110VAC)
	Philips Ultralume Fluorescent (110VAC)"


I got the second data set from : 
http://www.cs.sfu.ca/~colour/data/colour_constancy_synthetic_test_data/measured_with_sources.illum.gz

	The second "set consists of 81 spectra measured in and around the SFU campus at various times 	
	of the day, and in a variety of weather conditions"


For a reference, see: 
	Kobus Barnard, Lindsay Martin, Brian Funt, and Adam Coath,
	A Data Set for Colour Research,
	Color Research and Application, Volume 27, Number 3, pp. 147-151, 2002. 
http://www.cs.arizona.edu/people/kobus/research/publications/data_for_colour_research/data_for_color_research.pdf


 I interpolated the data so that it would create a 31x102 matrix 
representing 102 illuminants defined in terms of 31 wavelength samples, 400-700nm in 10 nm steps.
If you plot the data you will see that the dimensionality of the data set is relatively small. 
We should be able to come up with a small set of illuminants from this 
and other data from which to base our illuminant transformations for Experiment 3.
