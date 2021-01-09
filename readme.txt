Data format:
-----------------------------------------------------------------

Each line contains 28 columns:

RAW stands for Raw data
CAL stands for calibrated data
-----------------------------------------------------------------
Column1		Timestamp RAW no units
Column2		Timestamp CAL mSecs
Column3		Low Noise Accelerometer X RAW no units
Column4		Low Noise Accelerometer X CAL m/(sec^2)*
Column5 	Low Noise Accelerometer Y RAW no units
Column6		Low Noise Accelerometer Y CAL m/(sec^2)*
Column7		Low Noise Accelerometer Z RAW no units
Column8		Low Noise Accelerometer Z CAL m/(sec^2)*
Column9		Wide Range Accelerometer X RAW no units
Column10	Wide Range Accelerometer X CAL m/(sec^2)*
Column11	Wide Range Accelerometer Y RAW no units
Column12	Wide Range Accelerometer Y CAL m/(sec^2)*
Column13	Wide Range Accelerometer Z RAW no units 
Column14	Wide Range Accelerometer Z CAL m/(sec^2)*
Column15	Gyroscope X RAW no units
Column16	Gyroscope X CAL deg/sec*
Column17	Gyroscope Y RAW no units
Column18	Gyroscope Y CAL deg/sec*
Column19	Gyroscope Z RAW no units
Column20	Gyroscope Z CAL deg/sec*
Column21	Magnetometer X RAW no units
Column22	Magnetometer X CAL local*
Column23	Magnetometer Y RAW no units
Column24	Magnetometer Y CAL local*
Column25	Magnetometer Z RAW no units
Column26	Magnetometer Z CAL local*
Column27	VSenseBatt no units
Column28	VSenseBatt mVolts

Data file names:
-----------------------------------------------------------------
There are 30 participants (directories). 
In each directory there are 10 activites for related participants.
Directory names refer fake name of each participant.
In each directory activity names are defined as follows:


Activity Name			Turkish Activity Name
-----------------               ---------------------
cleaning window			cam silme
chopping			dograma
writing with a pen		el yazisi
eating soup			kaseden icme
using a computer mouse		klasor tasima
writing with a keyboard		klavye yazisi
cleaning table			masa silme
drinking water			su icme
using a tablet computer		tablet
kneading dough			yogurma


Example : furkancamsilme.csv stands for: 
	  furkan--> participant fake name
	  camsilme--> activity name

		  
The sampling rate is 52 Hz.



