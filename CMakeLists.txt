cmake_minimum_required(VERSION 3.10...3.31 FATAL_ERROR)

set(PROJECT_NAME essoradm)
project(${PROJECT_NAME})

#Pretty colors
set(CMAKE_COLOR_MAKEFILE ON)
#Dont force verbose
set(CMAKE_VERBOSE_MAKEFILE ON)
#Include current dir
set(CMAKE_INCLUDE_CURRENT_DIR TRUE)

INCLUDE(CheckIncludeFile)
INCLUDE(CheckCCompilerFlag)
INCLUDE(CheckCXXCompilerFlag)
INCLUDE(CheckTypeSize)

# Version
set(ESSORADM_VERSION_MAJOR "1")
set(ESSORADM_VERSION_MINOR "0")
set(ESSORADM_VERSION_PATCH "0")
set(SLIM_VERSION "${ESSORADM_VERSION_MAJOR}.${ESSORADM_VERSION_MINOR}.${ESSORADM_VERSION_PATCH}")

set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Installation Directory")
set(PKGDATADIR "${CMAKE_INSTALL_PREFIX}/share/essoradm")
set(SYSCONFDIR "/etc")
set(LIBDIR "/lib")
set(MANDIR "${CMAKE_INSTALL_PREFIX}/share/man")

set(SLIM_DEFINITIONS)
if(${CMAKE_SYSTEM_NAME} MATCHES "FreeBSD" OR
		${CMAKE_SYSTEM_NAME} MATCHES "NetBSD" OR
		${CMAKE_SYSTEM_NAME} MATCHES "OpenBSD"
		)
	set(SLIM_DEFINITIONS ${SLIM_DEFINITIONS} "-DNEEDS_BASENAME")
else()
	set(SLIM_DEFINITIONS ${SLIM_DEFINITIONS} "-DHAVE_SHADOW")
endif()

set(SLIM_DEFINITIONS ${SLIM_DEFINITIONS} "-DPACKAGE=\"EssoraDM\"")
set(SLIM_DEFINITIONS ${SLIM_DEFINITIONS} "-DVERSION=\"${SLIM_VERSION}\"")
set(SLIM_DEFINITIONS ${SLIM_DEFINITIONS} "-DPKGDATADIR=\"${PKGDATADIR}\"")
set(SLIM_DEFINITIONS ${SLIM_DEFINITIONS} "-DSYSCONFDIR=\"${SYSCONFDIR}\"")

# Flags
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -g -O2")
set(CMAKE_CPP_FLAGS "${CMAKE_CPP_FLAGS} -Wall -g -O2")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -g -O2")

# source 
set(essoradm_srcs
	main.cpp
	app.cpp
	numlock.cpp
	switchuser.cpp
	png.c
	jpeg.c
)

# EssoraDMlock removed in EssoraDM fork

set(common_srcs
    cfg.cpp
    image.cpp
    log.cpp
    panel.cpp
    util.cpp
)
if(USE_PAM)
	set(common_srcs ${common_srcs} PAM.cpp)
    # PAM enabled for EssoraDM authentication.
endif(USE_PAM)

# Build common library
set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libraries")

if (BUILD_SHARED_LIBS)
	message(STATUS "Enable shared library building")
	add_library(libessoradm ${common_srcs})
else(BUILD_SHARED_LIBS)
	message(STATUS "Disable shared library building")
	add_library(libessoradm STATIC ${common_srcs})
endif(BUILD_SHARED_LIBS)

if(USE_CONSOLEKIT)
	set(essoradm_srcs ${essoradm_srcs} Ck.cpp)
endif(USE_CONSOLEKIT)

add_executable(${PROJECT_NAME} ${essoradm_srcs})


#Set the custom CMake module directory where our include/lib finders are
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")

find_package(X11 REQUIRED)
find_package(Freetype REQUIRED)
find_package(JPEG REQUIRED)
find_package(PNG REQUIRED)
find_package(ZLIB REQUIRED)

# Fontconfig
set(FONTCONFIG_DIR ${CMAKE_MODULE_PATH})
find_package(FONTCONFIG REQUIRED)
if(FONTCONFIG_FOUND)
	message("\tFontConfig Found")
	target_link_libraries(${PROJECT_NAME} ${FONTCONFIG_LIBRARY})
	include_directories(${FONTCONFIG_INCLUDE_DIR})
endif(FONTCONFIG_FOUND)

# PAM
if(USE_PAM)
	message("\tPAM Enabled")
	find_package(PAM)
	if(PAM_FOUND)
		message("\tPAM Found")
		set(SLIM_DEFINITIONS ${SLIM_DEFINITIONS} "-DUSE_PAM")
		target_link_libraries(${PROJECT_NAME} ${PAM_LIBRARY})
		include_directories(${PAM_INCLUDE_DIR})
	else(PAM_FOUND)
		message("\tPAM Not Found")
	endif(PAM_FOUND)
else(USE_PAM)
	message("\tPAM disabled")
endif(USE_PAM)

# ConsoleKit
if(USE_CONSOLEKIT)
	find_package(CkConnector)
	message("\tConsoleKit Enabled")
	if(CKCONNECTOR_FOUND)
		message("\tConsoleKit Found")
		# DBus check
		find_package(DBus REQUIRED)
		if(DBUS_FOUND)
			message("\tDBus Found")
			target_link_libraries(${PROJECT_NAME} ${DBUS_LIBRARIES})
			include_directories(${DBUS_ARCH_INCLUDE_DIR})
			include_directories(${DBUS_INCLUDE_DIR})
			set(SLIM_DEFINITIONS ${SLIM_DEFINITIONS} "-DUSE_CONSOLEKIT")
			target_link_libraries(${PROJECT_NAME} ${CKCONNECTOR_LIBRARIES})
			include_directories(${CKCONNECTOR_INCLUDE_DIR})
		else(DBUS_FOUND)
			message("\tDBus Not Found")
		endif(DBUS_FOUND)
	else(CKCONNECTOR_FOUND)
		message("\tConsoleKit Not Found")
		message("\tConsoleKit disabled")
	endif(CKCONNECTOR_FOUND)
else(USE_CONSOLEKIT)
	message("\tConsoleKit disabled")
endif(USE_CONSOLEKIT)

# system librarys
find_library(M_LIB m)
find_library(RT_LIB rt)
find_library(CRYPTO_LIB crypt)
find_package(Threads)

add_definitions(${SLIM_DEFINITIONS})

#Set up include dirs with all found packages
include_directories(
	${X11_INCLUDE_DIR}
	${X11_Xft_INCLUDE_PATH}
	${X11_Xrender_INCLUDE_PATH}
	${X11_Xrandr_INCLUDE_PATH}
	${FREETYPE_INCLUDE_DIR_freetype2}
	${X11_Xmu_INCLUDE_PATH}
	${ZLIB_INCLUDE_DIR}
	${JPEG_INCLUDE_DIR}
	${PNG_INCLUDE_DIR}
)

target_link_libraries(libessoradm
    ${JPEG_LIBRARIES}
    ${PNG_LIBRARIES}
    ${ZLIB_LIBRARY}
)

#Set up library with all found packages for EssoraDM
#
# IMPORTANT:
# libessoradm is a static library. With GNU ld, dependency order matters:
# objects/static libs that need symbols must appear BEFORE the libraries
# that provide those symbols. Therefore libessoradm must come before
# Xft/Xrandr/PAM/etc.
target_link_libraries(${PROJECT_NAME}
    libessoradm

    ${X11_X11_LIB}
    ${X11_Xft_LIB}
    ${X11_Xrender_LIB}
    ${X11_Xrandr_LIB}
    ${X11_Xmu_LIB}

    ${FONTCONFIG_LIBRARY}
    ${FREETYPE_LIBRARY}

    ${PAM_LIBRARY}

    ${JPEG_LIBRARIES}
    ${PNG_LIBRARIES}
    ${ZLIB_LIBRARY}

    ${M_LIB}
    ${RT_LIB}
    ${CRYPTO_LIB}
    ${CMAKE_THREAD_LIBS_INIT}
)

####### install
# EssoraDM
install(TARGETS essoradm RUNTIME DESTINATION bin)

if (BUILD_SHARED_LIBS)
	set_target_properties(libessoradm PROPERTIES
		OUTPUT_NAME essoradm
		SOVERSION ${SLIM_VERSION})

	install(TARGETS libessoradm
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
	)
endif (BUILD_SHARED_LIBS)

# man file
install(FILES essoradm.1 DESTINATION ${MANDIR}/man1/)
# configure
install(FILES essoradm.conf DESTINATION ${SYSCONFDIR})
# systemd service file
if (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	# EssoraDM targets init systems manually; no systemd unit installed by default
endif (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
# themes directory
subdirs(themes)
