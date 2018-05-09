# ==============================================================================
# Shared config
# ==============================================================================
# setup some values before calling shared config

add_definitions(-DBUILDING_XMPCORE_LIB=1 -DXMP_COMPONENT_INT_NAMESPACE=AdobeXMPCore_Int)
if (NOT BUILD_SHARED_LIBS)
	add_definitions(-DBUILDING_XMPCORE_AS_STATIC=1)
else()
	add_definitions(-DBUILDING_XMPCORE_AS_DYNAMIC=1)
endif()

set(TP_ZUID_PATH "${XMPROOT_DIR}/third-party/zuid/interfaces")
set(TP_EXPAT_PATH "${XMPROOT_DIR}/third-party/expat/lib/")

# ==============================================================================
# For convenience we define the sources as a variable. You can add 
# header files and cpp/c files and CMake will sort them out
# ==============================================================================

list (APPEND INTERNAL_HEADER_FILES
    ${XMPROOT_DIR}/source/ExpatAdapter.hpp
    ${XMPROOT_DIR}/source/UnicodeConversions.hpp
    ${XMPROOT_DIR}/source/UnicodeInlines.incl_cpp
    ${XMPROOT_DIR}/source/XMLParserAdapter.hpp
	${XMPROOT_DIR}/build/XMP_BuildInfo.h
	source/XMPCore_Impl.hpp
	source/XMPIterator.hpp
	source/XMPMeta.hpp
	source/XMPUtils.hpp
	)
source_group("Header Files\\Private\\XMPCore" FILES ${INTERNAL_HEADER_FILES})

if (INCLUDE_CPP_DOM_SOURCE)
	file (GLOB_RECURSE PRIVATE_XMPCOMMON_HEADERS ${XMPROOT_DIR}/XMPCommon/*.h)
	source_group("Header Files\\Private\\XMPCommon" FILES ${PRIVATE_XMPCOMMON_HEADERS})

	file (GLOB_RECURSE PRIVATE_XMPCOMMON_SOURCES ${XMPROOT_DIR}/XMPCommon/source/*.cpp)
	source_group("Source Files\\Private\\XMPCommon" FILES ${PRIVATE_XMPCOMMON_SOURCES})
endif (INCLUDE_CPP_DOM_SOURCE)

file (GLOB PRIVATE_XMPCORE_HEADERS 
	${XMPROOT_DIR}/XMPCore/*.h 
	${XMPROOT_DIR}/XMPCore/ImplHeaders/*.h 
	${XMPROOT_DIR}/XMPCore/headers/*.h 
	${XMPROOT_DIR}/XMPCore/Interfaces/*.h )
source_group("Header Files\\Private\\XMPCore" FILES ${PRIVATE_XMPCORE_HEADERS})
	
file (GLOB_RECURSE PUBLIC_CLIENTGLUE_HEADER_FILES ${XMPROOT_DIR}/public/include/client-glue/*.*)
list (REMOVE_ITEM PUBLIC_CLIENTGLUE_HEADER_FILES
	${XMPROOT_DIR}/public/include/client-glue/TXMPFiles.incl_cpp
	${XMPROOT_DIR}/public/include/client-glue/WXMPFiles.hpp
	)
source_group("Header Files\\Public\\Client Glue" FILES ${PUBLIC_CLIENTGLUE_HEADER_FILES})

file (GLOB PUBLIC_HEADER_FILES ${XMPROOT_DIR}/public/include/*.*)
list (REMOVE_ITEM PUBLIC_HEADER_FILES
	${XMPROOT_DIR}/public/include/TXMPFiles.hpp
	${XMPROOT_DIR}/public/include/XMP_IO.hpp
	)
source_group("Header Files\\Public" FILES ${PUBLIC_HEADER_FILES})

file (GLOB_RECURSE PUBLIC_XMPCOMMON_HEADERS ${XMPROOT_DIR}/public/include/XMPCommon/*.h )
source_group("Header Files\\Public\\XMPCommon" FILES ${PUBLIC_XMPCOMMON_HEADERS})

file (GLOB_RECURSE PUBLIC_XMPCOMMON_SOURCES ${XMPROOT_DIR}/public/include/XMPCommon/source/*.cpp )
source_group("Source Files\\Public\\XMPCommon" FILES ${PUBLIC_XMPCOMMON_SOURCES})

file (GLOB_RECURSE PUBLIC_XMPCORE_HEADERS ${XMPROOT_DIR}/public/include/XMPCore/*.h)
source_group("Header Files\\Public\\XMPCore" FILES ${PUBLIC_XMPCORE_HEADERS})

file (GLOB_RECURSE PUBLIC_XMPCORE_SOURCES ${XMPROOT_DIR}/public/include/XMPCore/source/*.cpp )
source_group("Source Files\\Public\\XMPCore" FILES ${PUBLIC_XMPCORE_SOURCES})

file (GLOB ABIWRAPPER_SOURCE_FILES source/WXMP*.cpp)
source_group("Source Files\\ABI Wrappers" FILES ${ABIWRAPPER_SOURCE_FILES})

if (INCLUDE_CPP_DOM_SOURCE)
	file (GLOB PRIVATE_XMPCORE_ISOURCE_FILES source/*_I.cpp)
	file (GLOB PRIVATE_XMPCORE_IMPLSOURCE_FILES source/*Impl.cpp)
	list (REMOVE_ITEM PRIVATE_XMPCORE_IMPLSOURCE_FILES source/XMPCore_Impl.cpp)
	source_group("Source Files\\Private\\XMPCore" FILES ${PRIVATE_XMPCORE_ISOURCE_FILES} ${PRIVATE_XMPCORE_IMPLSOURCE_FILES})
else (INCLUDE_CPP_DOM_SOURCE)
	file (GLOB PRIVATE_XMPCORE_IMPLSOURCE_FILES source/CoreObjectFactoryImpl.cpp)
	source_group("Source Files\\Private\\XMPCore" FILES ${PRIVATE_XMPCORE_IMPLSOURCE_FILES})
endif (INCLUDE_CPP_DOM_SOURCE)

#XMP Core classes
file (GLOB CORECLASS_SOURCE_FILES source/XMP*.cpp)
list (REMOVE_ITEM CORECLASS_SOURCE_FILES source/XMPCore_Impl.cpp)
source_group("Source Files\\Core Classes" FILES ${CORECLASS_SOURCE_FILES})

file (GLOB THIRDPARTY_SOURCE_FILES ${TP_ZUID_PATH}/*.cpp)

list (APPEND THIRDPARTY_SOURCE_FILES
	${TP_EXPAT_PATH}/xmlparse.c
	${TP_EXPAT_PATH}/xmlrole.c
	${TP_EXPAT_PATH}/xmltok.c
	)

if(WIN32)
	list (APPEND THIRDPARTY_SOURCE_FILES resource/win/expat_config.h)
else()
	list (APPEND THIRDPARTY_SOURCE_FILES resource/${XMP_PLATFORM_SHORT}/expat_config.h)
endif()

list (APPEND UTILITY_SOURCE_FILES
	source/ExpatAdapter.cpp
	source/ParseRDF.cpp
	source/XMPCore_Impl.cpp
	${XMPROOT_DIR}/source/UnicodeConversions.cpp
	${XMPROOT_DIR}/source/XML_Node.cpp
	${XMPROOT_DIR}/source/XMP_LibUtils.cpp
	)
source_group("Source Files\\Utilities" FILES ${UTILITY_SOURCE_FILES})

#resource files
if (WIN32)
	file (GLOB RESOURCE_FILES resource/win/*.*)
else ()
	file (GLOB RESOURCE_FILES resource/${XMP_PLATFORM_SHORT}/*.*)
endif()

if(WIN32 AND NOT BUILD_SHARED_LIBS)
	list(REMOVE_ITEM RESOURCE_FILES resource/${XMP_PLATFORM_SHORT}/XMPCore.rc)
endif()
source_group("Resource Files" FILES resource})


# include directories
include_directories(${XMPROOT_DIR})
include_directories(${XMPROOT_DIR}/public/include)
include_directories(${XMPROOT_DIR}/third-party/expat/public/lib)
include_directories(resource/${XMP_PLATFORM_SHORT})
if(UNIX AND NOT APPLE AND BUILD_SHARED_LIBS)
include_directories(${XMPROOT_DIR}/XMPCore/third-party/uuid/include)
endif()
if (WIN32)
	include_directories(resource/win)
else ()
	include_directories(resource/${XMP_PLATFORM_SHORT})
endif ()

#additional link directory
link_directories(${OUTPUT_DIR})


# ==============================================================================
# Define what to do, lib, exe, etc 
if (UNIX AND APPLE AND BUILD_SHARED_LIBS)
	# preprocess Info.plist
	#if (${CMAKE_BUILD_TYPE} strequal "Debug")
	if((${CMAKE_BUILD_TYPE} MATCHES "Debug") OR (${CMAKE_BUILD_TYPE} MATCHES "debug"))
			set (INFO_PLIST_FLAGS "-DDEBUG=1")
	else()
		set (INFO_PLIST_FLAGS "-DNDEBUG=1")
	endif()
	if(NOT APPLE_IOS)
		add_custom_target(XMPCoreInfoPlist
			COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}
			COMMAND if [ $(CONFIGURATION) != Debug ]; then
				${GCCTOOL} -E -P -x c resource/${XMP_PLATFORM_SHORT}/XMPCore.plist
				-F${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/
				-DPRODUCT_NAME=XMPCore -DMAC_ENV=1 -DNDEBUG=1
				-include resource/${XMP_PLATFORM_SHORT}/XMPCorePList.h
				-o ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Info.plist
				\; else
				${GCCTOOL} -E -P -x c resource/${XMP_PLATFORM_SHORT}/XMPCore.plist
				-F${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/
				-DPRODUCT_NAME=XMPCore -DMAC_ENV=1 -DDEBUG=1
				-include resource/${XMP_PLATFORM_SHORT}/XMPCorePList.h
				-o ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Info.plist
				\; fi
			COMMAND rm -f ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/../CMakeFiles/XMPCore.dir/Info.plist
			COMMAND cp ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Info.plist ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/../CMakeFiles/XMPCore.dir/Info.plist
			COMMENT "Preprocessing Info-plist"
		)
	else()
		add_custom_target(XMPCoreInfoPlist
			COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}
			COMMAND if [ $(CONFIGURATION) != Debug ]; then
				${GCCTOOL} -E -P -x c resource/ios/XMPCore.plist
				-F${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/
				-DPRODUCT_NAME=XMPCore -DIOS_ENV=1 -DNDEBUG=1
				-include resource/ios/XMPCorePList.h
				-o ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Info.plist
				\; else
				${GCCTOOL} -E -P -x c resource/ios/XMPCore.plist
				-F${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/
				-DPRODUCT_NAME=XMPCore -DIOS_ENV=1 -DDEBUG=1
				-include resource/ios/XMPCorePList.h
				-o ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Info.plist
				\; fi
			COMMAND rm -f ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/../CMakeFiles/XMPCore.dir/Info.plist
			COMMAND cp ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/Info.plist ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/../CMakeFiles/XMPCore.dir/Info.plist
			COMMENT "Preprocessing Info-plist"
		)
	endif()
	set(DEPENDENCY_LIST "ALL:XMPCoreInfoPlist")
else ()
	set(DEPENDENCY_LIST "")
endif()

add_library(XMPCore
    ${PUBLIC_CLIENTGLUE_HEADER_FILES}
    ${PUBLIC_HEADER_FILES}
    ${INTERNAL_HEADER_FILES}
    ${ABIWRAPPER_SOURCE_FILES}
    ${ABIWRAPPER_SOURCE_FILES}
    ${CORECLASS_SOURCE_FILES}
    ${THIRDPARTY_SOURCE_FILES}
    ${UTILITY_SOURCE_FILES}
    ${PRIVATE_XMPCORE_ISOURCE_FILES}
    ${PRIVATE_XMPCORE_IMPLSOURCE_FILES}
    ${PRIVATE_XMPCOMMON_HEADERS}
    ${PRIVATE_XMPCOMMON_SOURCES}
    ${PRIVATE_XMPCORE_HEADERS}
    ${PUBLIC_XMPCOMMON_HEADERS}
    ${PUBLIC_XMPCOMMON_SOURCES}
    ${PUBLIC_XMPCORE_HEADERS}
    ${PUBLIC_XMPCORE_SOURCES}
    ${RESOURCE_FILES}
)

# ==============================================================================
# Link dependencies
set(FRAMEWORK_LIST "ALL:CoreFoundation" "Mac:CoreServices")
AddMacFramework(XMPCore FRAMEWORK_LIST)


if(WIN32)
    SetWinLinkFlags(XMPCore "rpcrt4.lib" "XMPCore")
else()
	if(UNIX AND NOT APPLE)
		SetWinLinkFlags(XMPCore "-Xlinker --version-script -Xlinker \"resource/${XMP_PLATFORM_SHORT}/XMPCore.exp\"" "")
	else()
        if(APPLE_IOS AND BUILD_SHARED_LIBS)
			set_target_properties(XMPCore PROPERTIES XCODE_ATTRIBUTE_DYLIB_INSTALL_NAME_BASE "@rpath")
			set_target_properties(XMPCore PROPERTIES XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.adobe.AdobeXMPCore")
		endif()
		set_target_properties(XMPCore PROPERTIES BUILD_WITH_INSTALL_RPATH ON INSTALL_NAME_DIR "@executable_path/../Frameworks")
		SetWinLinkFlags(XMPCore "-unexported_symbols_list \"resource/${XMP_PLATFORM_SHORT}/XMPCore.unexp\"" "XMPCore")
		set_target_properties(XMPCore PROPERTIES XCODE_ATTRIBUTE_GCC_SYMBOLS_PRIVATE_EXTERN "YES")
	endif()
endif()

message (STATUS "===========================================================================")
message (STATUS " ${PROJECT_NAME} ")
message (STATUS "===========================================================================")
message (STATUS " OUTPUT_DIR = ${OUTPUT_DIR}")


