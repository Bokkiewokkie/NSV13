//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		//Debug/Special Maps
		#include "map_files\Mining\Lavaland.dmm"
		#include "map_files\debug\runtimestation.dmm"

		//Hammerhead
		#include "map_files\Gladius\Hammerhead.dmm"

		//Enterprise
		#include "map_files\Enterprise\Enterprise1.dmm"
		#include "map_files\Enterprise\Enterprise2.dmm"

		//Jeppison
		#include "map_files\Jeppison\Jeppison1.dmm"
		#include "map_files\Jeppison\Jeppison2.dmm"

		//Vago
		#include "map_files\Vago\Vago1.dmm"
		#include "map_files\Vago\Vago2.dmm"

		//Galactica
		#include "map_files\Galactica\Galactica1.dmm"
		#include "map_files\Galactica\Galactica2.dmm"

		//Eclipse
		#include "map_files\Eclipse\Eclipse1.dmm"
		#include "map_files\Eclipse\Eclipse2.dmm"

		#ifdef CIBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
