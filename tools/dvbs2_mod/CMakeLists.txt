cmake_minimum_required(VERSION 3.12)

file(GLOB_RECURSE SimpleDump_testing_CPPS *.cpp)

add_executable(dvbs2_mod ${SimpleDump_testing_CPPS})
target_include_directories(dvbs2_mod PUBLIC src-testing src-core ../../plugins/dvb_support)

# Link against the core
target_link_libraries(dvbs2_mod PUBLIC simpledump_core dvb_support)