# ==============================================================================
# XMP config for XMPTOOLKIT and TestRunner
# ==============================================================================

set(INCLUDE_CPP_DOM_SOURCE TRUE)

if (INCLUDE_CPP_DOM_SOURCE)
	add_definitions(-DENABLE_CPP_DOM_MODEL=1)
else ()
	add_definitions(-DENABLE_CPP_DOM_MODEL=0)
endif()

include(cmake/XMP_ConfigCommon.cmake REQUIRED)
