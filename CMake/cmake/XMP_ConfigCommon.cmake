#add definition specific to XMP and shared by all projects
add_definitions(-DXML_STATIC=1 -DHAVE_EXPAT_CONFIG_H=1 )

if(BUILD_SHARED_LIBS)
	add_definitions(-DXMP_DynamicBuild=1)
else()
	add_definitions(-DXMP_StaticBuild=1)
endif()

#add_definitions(-DBUILDING_XMPCOMMON_LIB=1)

set (XMPROOT_DIR ${XMP_ROOT})
set (COMPONENT XMP)

# Load project specific MACRO, VARIABLES; set for component and pass to the common file where there are set
include(cmake/ProductConfig.cmake REQUIRED)
include(cmake/SharedConfig.cmake REQUIRED)

