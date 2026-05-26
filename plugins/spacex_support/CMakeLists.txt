cmake_minimum_required(VERSION 3.12)
project(spacex_support)


option(USE_VIDEO_ENCODER "Build the video encoder module, links against libav." OFF)

file(GLOB_RECURSE spacex_support_CPPS *.cpp)
add_library(spacex_support SHARED ${spacex_support_CPPS})
target_link_libraries(spacex_support PUBLIC simpledump_core)
target_include_directories(spacex_support PUBLIC src)

if(MSVC)
    if(USE_VIDEO_ENCODER)
        target_link_libraries(simpledump_core PUBLIC libavcodec.dll)
        target_link_libraries(simpledump_core PUBLIC libavformat.dll)
        target_link_libraries(simpledump_core PUBLIC libavutil.dll)
        target_link_libraries(simpledump_core PUBLIC libavfilter.dll)

        # Enable it
        target_compile_definitions(simpledump_core PUBLIC USE_VIDEO_ENCODER="1")
    endif()
    install(TARGETS spacex_support DESTINATION ${CMAKE_INSTALL_LIBDIR}/simpledump/plugins RUNTIME_DEPENDENCY_SET simpledump_deps)
elseif(ANDROID)
# NO encoder on Android
install(TARGETS spacex_support DESTINATION ${CMAKE_INSTALL_LIBDIR}/simpledump/plugins)
else()
    if(USE_VIDEO_ENCODER)
        # libavcodec
        find_library(AVCODEC_LIBRARY avcodec REQUIRED)
        target_link_libraries(simpledump_core PUBLIC ${AVCODEC_LIBRARY})

        # libavformat
        find_library(AVFORMAT_LIBRARY avformat REQUIRED)
        target_link_libraries(simpledump_core PUBLIC ${AVFORMAT_LIBRARY})

        # libavutil
        find_library(AVUTIL_LIBRARY avutil REQUIRED)
        target_link_libraries(simpledump_core PUBLIC ${AVUTIL_LIBRARY})

        # libavfilter
        find_library(AVFILTER_LIBRARY avfilter REQUIRED)
        target_link_libraries(simpledump_core PUBLIC ${AVFILTER_LIBRARY})

        # Enable it
        target_compile_definitions(simpledump_core PUBLIC USE_VIDEO_ENCODER="1")
    endif()
    install(TARGETS spacex_support DESTINATION ${CMAKE_INSTALL_LIBDIR}/simpledump/plugins)
endif()