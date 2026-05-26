cmake_minimum_required(VERSION 3.12)

file(GLOB_RECURSE SimpleDump_testing_CPPS *.cpp)

add_executable(cadu_rs_derand ${SimpleDump_testing_CPPS})
target_include_directories(cadu_rs_derand PUBLIC src-testing src-core)

# Link against the core
target_link_libraries(cadu_rs_derand PUBLIC simpledump_core)