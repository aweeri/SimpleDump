cmake_minimum_required(VERSION 3.12)

file(GLOB_RECURSE SimpleDump_testing_CPPS main.cpp)

add_executable(simpledump-testing ${SimpleDump_testing_CPPS})
target_include_directories(simpledump-testing PUBLIC src-testing src-core)

# Link against the core
target_link_libraries(satdump-testing PUBLIC simpledump_core) # mfhdf)