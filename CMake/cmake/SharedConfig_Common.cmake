# ==============================================================================
# Function: architecture related settings
# ==============================================================================
function(SetupTargetArchitecture)
	if(APPLE_IOS)
		set(${COMPONENT}_CPU_FOLDERNAME	"$(ARCHS)" PARENT_SCOPE)
	else()
		if(CMAKE_CL_64)
			set(${COMPONENT}_BITDEPTH		"64" PARENT_SCOPE)
			set(${COMPONENT}_CPU_FOLDERNAME	"intel_64" PARENT_SCOPE)
		else()
			set(${COMPONENT}_BITDEPTH		"32" PARENT_SCOPE)
			set(${COMPONENT}_CPU_FOLDERNAME	"intel" PARENT_SCOPE)
		endif()
	endif()
endfunction(SetupTargetArchitecture)

# ==============================================================================
# Function: Set internal build target directory. See ${COMPONENT}_PLATFORM_FOLDER for 
# further construction and when CMAKE_CFG_INTDIR/CMAKE_BUILD_TYPE are set 
# (generator dependent).
# ==============================================================================
function(SetupInternalBuildDirectory)
	if(CMAKE_CFG_INTDIR STREQUAL ".")
		# CMAKE_BUILD_TYPE only available for makefile builds
		set(${COMPONENT}_IS_MAKEFILE_BUILD	"ON" PARENT_SCOPE)
		if((${CMAKE_BUILD_TYPE} MATCHES "Debug") OR (${CMAKE_BUILD_TYPE} MATCHES "debug") )
			set(${COMPONENT}_BUILDMODE_DIR "debug" PARENT_SCOPE)
		else()
			set(${COMPONENT}_BUILDMODE_DIR "release" PARENT_SCOPE)
		endif()
	else()
		# Visual/XCode have dedicated Debug/Release target modes. CMAKE_CFG_INTDIR is set.
		if(APPLE_IOS)
# TODO: fixme
#			set(${COMPONENT}_BUILDMODE_DIR "$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)" PARENT_SCOPE)
			set(${COMPONENT}_BUILDMODE_DIR "$(CONFIGURATION)" PARENT_SCOPE)
		else()
			set(${COMPONENT}_BUILDMODE_DIR ${CMAKE_CFG_INTDIR} PARENT_SCOPE)
		endif()
		set(${COMPONENT}_IS_MAKEFILE_BUILD	"OFF" PARENT_SCOPE)
	endif()
endfunction(SetupInternalBuildDirectory)


# ==============================================================================
# Function: Setup various complier flags
# ==============================================================================
function(SetupCompilerFlags)
	if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX)
	    set(OUTPUT_VARIABLE "")
		# Execute GCC with the -dumpversion option, to give us a version string
		execute_process(COMMAND ${CMAKE_CXX_COMPILER} "-dumpversion" OUTPUT_VARIABLE GCC_VERSION_STRING)
	
		# Match only the major and minor versions of the version string
		string(REGEX MATCH "[0-9]+.[0-9]+.[0-9]" GCC_MAJOR_MINOR_VERSION_STRING "${GCC_VERSION_STRING}")
	
		# Strip out the period between the major and minor versions
		string(REGEX REPLACE "\\." "" ${COMPONENT}_VERSIONING_GCC_VERSION "${GCC_MAJOR_MINOR_VERSION_STRING}")
	
		# Set the GCC versioning toolset
		if(NOT DEFINED ${COMPONENT}_TOOLSET)
			set(${COMPONENT}_VERSIONING_GCC_VERSION "${${COMPONENT}_VERSIONING_GCC_VERSION}" PARENT_SCOPE)
			set(${COMPONENT}_TOOLSET "-D${COMPONENT}_TOOLSET_GCC${${COMPONENT}_VERSIONING_GCC_VERSION}" PARENT_SCOPE)
		endif()
	
		# workaround for visibility problem and gcc 4.1.x
        if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS_EQUAL 4.1)
			# only remove inline hidden...
			string(REGEX REPLACE "-fvisibility-inlines-hidden" "" CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS})
		endif()
	endif()
	
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${${COMPONENT}_PREPROCESSOR_FLAGS}" PARENT_SCOPE)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${${COMPONENT}_PREPROCESSOR_FLAGS}" PARENT_SCOPE)
endfunction(SetupCompilerFlags)


# ==============================================================================
# Function: Converts a semicolon separated list into whitespace separated string
# ==============================================================================
# usage: ConvertListToString("${SRC}" DEST)
#
function(ConvertListToString list string)
	set(result "")
	foreach(item ${list})
		set(result "${result} ${item}")
	endforeach()
	set(${string} ${result} PARENT_SCOPE)
endfunction(ConvertListToString)

# =======================================================================
# Function: Determine XCode version installed on current machine
# =======================================================================
#
function(DetectXCodeVersion)
	# get xcode version
	execute_process(
			  COMMAND xcodebuild -version
			  OUTPUT_VARIABLE CMAKE_INSTALLED_XCODE_VERSION
			  OUTPUT_STRIP_TRAILING_WHITESPACE
	)
	string(REGEX MATCH "Xcode ([3-9].[0-9][.]?[0-9]?)" matches ${CMAKE_INSTALLED_XCODE_VERSION})
	#message("Matches1: ${CMAKE_MATCH_1}")
	set(CMAKE_INSTALLED_XCODE_VERSION ${CMAKE_MATCH_1} PARENT_SCOPE)
	#message("CMAKE_INSTALLED_XCODE_VERSION :${CMAKE_INSTALLED_XCODE_VERSION}")
endfunction(DetectXCodeVersion)

# ==============================================================================
# Function: Set the output path depending on isExecutable
# The output path is corrected. XCode and VS automatically add the selected target (debug/release)
# ==============================================================================
#
function(SetOutputPath path isExecutable)
	# remove last path item if not makefile
	if(NOT ${COMPONENT}_IS_MAKEFILE_BUILD)
		get_filename_component(correctedPath ${path} PATH)
		#message("SetOutputPath: ${path} to ${correctedPath}")
	else()
		set(correctedPath ${path})
	endif()
	
	# 
	if(isExecutable)
		set(EXECUTABLE_OUTPUT_PATH ${correctedPath} PARENT_SCOPE)
		#message("SetOutputPath: Set EXECUTABLE_OUTPUT_PATH to ${correctedPath} isExecutable=${isExecutable}")
	else()
		set(LIBRARY_OUTPUT_PATH ${correctedPath} PARENT_SCOPE)
		#message("SetOutputPath: Set LIBRARY_OUTPUT_PATH to ${correctedPath} isExecutable=${isExecutable}")
	endif()

endfunction(SetOutputPath)

# ==============================================================================
# Function: for backwards compatibility
# ==============================================================================
#
function(SetWinLinkFlags appname linkflags libname)
	SetPlatformLinkFlags("${appname}" "${linkflags}" "${libname}")
endfunction(SetWinLinkFlags)

# ==============================================================================
# Function: add source files and dependencies to target library
# parameter: targetName, target lib name which the dependencies add to
#            staticBuild, YES if target should be built as static lib, NO for dynamic
#            isFramework, YES if target should be built as a framework, otherwise NO.
#            sharedOrModule, SHARED if target should be built as shared library,
#                            MODULE if target should be built as module library,
#                            ignored if staticBuild is set to YES
#            sourceFiles, list of source files that associate with target
#            dependencyList, list of dependencies of the target, where
#                            "ALL:xxx" to add a dependency for either static or dynamic building,
#                            "DLL:xxx" to add a dependency for dynamic building only,
#                            "STATIC:xxx" to add a dependency for static building only
# ==============================================================================
#
function(AddLibraryAndDependencies targetName staticBuild isFramework sharedOrModule sourceFiles dependencyList)
	if(staticBuild)
		add_library(${targetName} STATIC ${${sourceFiles}})
	else()
		add_library(${targetName} ${sharedOrModule} ${${sourceFiles}})
	endif()
	
	# message("-- ${targetName}: ${${dependencyList}}")
	foreach(dependencyPair ${${dependencyList}})
		string(REGEX MATCH "(ALL|DLL|STATIC):(.+)" matches ${dependencyPair})
		
		set(buildScope ${CMAKE_MATCH_1})
		set(theDependencies ${CMAKE_MATCH_2})
		
		if(${buildScope} MATCHES "ALL")
			set(final_dependencies ${final_dependencies} ${theDependencies})
		elseif(${buildScope} MATCHES "DLL")
			if(NOT staticBuild)
				set(final_dependencies ${final_dependencies} ${theDependencies})
			endif()
		elseif(${buildScope} MATCHES "STATIC")
			if(staticBuild)
				set(final_dependencies ${final_dependencies} ${theDependencies})
			endif()
		endif()
	endforeach()
	
	if(final_dependencies)
		add_dependencies(${targetName} ${final_dependencies})
		# message("-- final_dependencies: ${final_dependencies}")
	endif()
	
	if(NOT staticBuild)
		if(isFramework)
			set_target_properties(${targetName} PROPERTIES FRAMEWORK true)
		endif()
	endif()
endfunction(AddLibraryAndDependencies)

# ==============================================================================
# Function: Add single flag to target var such as CMAKE_C_FLAGS and CMAKE_CXX_FLAGS
# ==============================================================================
#
function(AddCompileFlag targetFlag flag)
	# string(FIND ${${targetFlag}} ${flag} found)
	# if(${found} MATCHES "-1")
		set(${targetFlag} "${flag} ${${targetFlag}}" PARENT_SCOPE)
	# endif()
endfunction(AddCompileFlag)

# ==============================================================================
# Function: Add flags to target var such as CMAKE_C_FLAGS and CMAKE_CXX_FLAGS
# ==============================================================================
#
function(AddCompileFlags targetFlag flagList)
	foreach(flag ${${flagList}})
		# string(FIND ${${targetFlag}} ${flag} found)
		# if(${found} MATCHES "-1")
			set(C_FLAGS_TO_ADD "${C_FLAGS_TO_ADD} ${flag}")
		# endif()
	endforeach()
	set(${targetFlag} "${C_FLAGS_TO_ADD} ${${targetFlag}}" PARENT_SCOPE)
endfunction(AddCompileFlags)

# ==============================================================================
# Function: Remove single flag from target var such as CMAKE_C_FLAGS 
#           and CMAKE_CXX_FLAGS
# ==============================================================================
#
function(RemoveCompileFlag targetFlag flag)
	if(NOT ${flag} STREQUAL "")
		string(STRIP ${flag} flag)
		if(NOT ${flag} STREQUAL "")
			string(REGEX REPLACE "${flag}" "" ${targetFlag} ${${targetFlag}})
		endif()
		set(${targetFlag} "${${targetFlag}}" PARENT_SCOPE)
	endif()
endfunction(RemoveCompileFlag)

# ==============================================================================
# Function: Remove flags from target var such as CMAKE_C_FLAGS 
#           and CMAKE_CXX_FLAGS
# ==============================================================================
#
function(RemoveCompileFlags targetFlag flagList)
	foreach(flag ${${flagList}})
		if(NOT ${flag} STREQUAL "")
			string(STRIP ${flag} flag)
			if(NOT ${flag} STREQUAL "")
				string(REGEX REPLACE "${flag}" "" ${targetFlag} ${${targetFlag}})
			endif()
		endif()
	endforeach()
	set(${targetFlag} "${${targetFlag}}" PARENT_SCOPE)
endfunction(RemoveCompileFlags)

