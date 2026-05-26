cmake_minimum_required(VERSION 3.12)

file(GLOB_RECURSE SimpleDump_testing_CPPS *.cpp)

add_executable(test_simpledump ${SimpleDump_testing_CPPS})
target_include_directories(test_simpledump PUBLIC src-testing src-core)

# Link against the core
target_link_libraries(test_simpledump PUBLIC simpledump_core)