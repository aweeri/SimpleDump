cmake_minimum_required(VERSION 3.12)

file(GLOB_RECURSE SimpleDump_testing_CPPS *.cpp)

add_executable(sdr_probe ${SimpleDump_testing_CPPS})
target_include_directories(sdr_probe PUBLIC src-testing src-core)

# Link against the core
target_link_libraries(sdr_probe PUBLIC simpledump_core)