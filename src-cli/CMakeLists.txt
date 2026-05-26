cmake_minimum_required(VERSION 3.12)

file(GLOB_RECURSE SimpleDump_cli_CPPS *.cpp)

add_executable(simpledump ${SimpleDump_cli_CPPS})
target_include_directories(simpledump PUBLIC src-cli src-core)

# Link against the core
target_link_libraries(simpledump PUBLIC simpledump_core)

install(TARGETS simpledump DESTINATION ${CMAKE_INSTALL_BINDIR})