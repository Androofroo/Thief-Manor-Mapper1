//#define LOWMEMORYMODE //uncomment this to load centcom and runtime station and thats it.

#include "map_files\generic\CentCom.dmm"

#ifndef LOWMEMORYMODE
	#ifdef ALL_MAPS
		#include "map_files\Roguetown\roguetown.dmm"
		#include "map_files\Rogueworld\Rogueworld.dmm"
		// Don't include Thief Manor here, it will be loaded via the map_config system
		//#include "map_files\Thief_Manor\ThiefManorWorld.dmm"

		#ifdef TRAVISBUILDING
			#include "templates.dm"
		#endif
	#endif
#endif
