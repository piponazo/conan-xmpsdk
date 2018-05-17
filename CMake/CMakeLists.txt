cmake_minimum_required(VERSION 3.5.2)

# ==============================================================================
# This project
option(CMAKE_CL_64 "64bit target?" ON)

set(TARGET_NAME XMPToolkitSDK)
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "Configurations" FORCE)

if(CMAKE_CL_64)
	project(${TARGET_NAME}64)
else()
	project(${TARGET_NAME})
endif()

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake REQUIRED)
conan_basic_setup()

set(XMP_ROOT ${PROJECT_SOURCE_DIR})

include(cmake/XMP_Config.cmake REQUIRED)
add_subdirectory(XMPCore)
#NOTE: probably we do not want this
#add_subdirectory(${XMP_ROOT}/XMPFiles/build ${XMP_ROOT}/XMPFiles/build/${XMP_CMAKEFOLDER_NAME})


# ==============================================================================
# configuration feedback
# ==============================================================================

message (STATUS "===========================================================================")
message (STATUS " ${TARGET_NAME} ")
#message (STATUS " Version = ${XMP_VERSION}")
message (STATUS "===========================================================================")
#message (STATUS " ${XMP_EXTRA_BUILDMACHINE}")
message (STATUS " 64 bit build is: ${CMAKE_CL_64}")
message (STATUS " Shared lib : ${BUILD_SHARED_LIBS}")
message (STATUS " ${TARGET_NAME} ")
message (STATUS " ${XMP_PLATFORM_LINK} ")
message (STATUS " ${XMP_GLOBALS}")
message (STATUS " Compiler: ")
message (STATUS " CC=${CMAKE_C_COMPILER}")
message (STATUS " CXX=${CMAKE_CXX_COMPILER}")
message (STATUS "===========================================================================")
