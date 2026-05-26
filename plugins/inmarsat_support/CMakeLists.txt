cmake_minimum_required(VERSION 3.12)
project(inmarsat_support)

# Check for sys/time.h availability (needed by libacars)
include(CheckIncludeFile)
check_include_file("sys/time.h" HAVE_SYS_TIME_H)
check_include_file("unistd.h" HAVE_UNISTD_H)

# Configure libacars config.h
configure_file(aero/libacars/config.h.in aero/libacars/config.h @ONLY)

file(GLOB_RECURSE inmarsat_support_CPPS *.cpp aero/libacars/*.c aero/mbelib/*.c)
add_library(inmarsat_support SHARED ${inmarsat_support_CPPS})
target_link_libraries(inmarsat_support PUBLIC simpledump_core)
target_include_directories(inmarsat_support PUBLIC src . ${CMAKE_CURRENT_BINARY_DIR})

if(MSVC)
    target_link_libraries(inmarsat_support PUBLIC ws2_32 zlib.dll)
endif()

install(TARGETS inmarsat_support DESTINATION ${CMAKE_INSTALL_LIBDIR}/simpledump/plugins)