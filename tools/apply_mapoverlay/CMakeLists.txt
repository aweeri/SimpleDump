cmake_minimum_required(VERSION 3.12)

file(GLOB_RECURSE SimpleDump_testing_CPPS *.cpp)

add_executable(apply_mapoverlay ${SimpleDump_testing_CPPS})
target_include_directories(apply_mapoverlay PUBLIC src-testing src-core)

# Link against the core
target_link_libraries(apply_mapoverlay PUBLIC simpledump_core)