include(cmake/SharedConfig_Common.cmake REQUIRED)

# ============================================================================
# Load platform specified configurations
# ============================================================================

#SetupTargetArchitecture()
#SetupInternalBuildDirectory()

if (UNIX)
	if (APPLE)
		if (APPLE_IOS)
            include(cmake/SharedConfig_Ios.cmake REQUIRED)
		else ()
            include(cmake/SharedConfig_Mac.cmake REQUIRED)
		endif ()
	else ()
        execute_process(COMMAND "uname" OUTPUT_VARIABLE OSNAME)
        string(TOUPPER "${OSNAME}" OSNAME)

        if ( ${OSNAME} MATCHES SUNOS)
            execute_process(COMMAND "uname" "-p" OUTPUT_VARIABLE PLATFORM_SUNOS_ARCH)
            string(TOUPPER "${PLATFORM_SUNOS_ARCH}" PLATFORM_SUNOS_ARCH)

            if ( ${PLATFORM_SUNOS_ARCH} MATCHES SPARC)
                include(cmake/SharedConfig_sunos_sparc.cmake REQUIRED)
            else()
                include(cmake/SharedConfig_sunos_intel.cmake REQUIRED)
            endif()
        else()
            include(cmake/SharedConfig_Linux.cmake REQUIRED)
        endif()
	endif ()
else ()
	if (WIN32)
        include(cmake/SharedConfig_Win.cmake REQUIRED)
	endif ()
endif ()

# ==============================================================================
# Debug feedback
# ==============================================================================

#message(STATUS " ${OUTPUT_DIR}")
#message(STATUS " ${${COMPONENT}_PLATFORM_FOLDER}")
#message(STATUS " ${${COMPONENT}_BUILDMODE_DIR}")
#message(STATUS " ${CMAKE_CXX_FLAGS}")
