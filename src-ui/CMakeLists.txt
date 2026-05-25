cmake_minimum_required(VERSION 3.12)

if(MSVC)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /SUBSYSTEM:windows /ENTRY:mainCRTStartup")
    enable_language("RC")
    set (WIN32_RESOURCES ../windows/resource.rc)
endif()

file(GLOB_RECURSE SimpleDump_ui_CPPS *.cpp imgui/gl3w/gl3w.c)
add_executable(simpledump-ui ${SimpleDump_ui_CPPS} ${WIN32_RESOURCES})
target_include_directories(simpledump-ui PUBLIC . ../src-core ../src-interface ../libsdr)

# Link against the core
target_link_libraries(simpledump-ui PUBLIC satdump_core satdump_interface)

# OpenGL or OpenGL ES
option(BUILD_GLES "Build the GUI with OpenGL ES" OFF)

if(BUILD_GLES)
    message("Building GUI with OpenGL ES")
    find_package(OpenGLES2 REQUIRED)
    target_compile_definitions(simpledump-ui PUBLIC IMGUI_IMPL_OPENGL_ES2)
    target_include_directories(simpledump-ui PUBLIC ${OPENGLES2_INCLUDE_DIR})
    target_link_libraries(simpledump-ui PUBLIC ${OPENGLES2_LIBRARIES})
else()
    message("Building GUI with OpenGL")
    set(OpenGL_GL_PREFERENCE GLVND)
    find_package(OpenGL REQUIRED)
    target_compile_definitions(simpledump-ui PUBLIC IMGUI_IMPL_OPENGL_LOADER_CUSTOM)
    target_include_directories(simpledump-ui PUBLIC ${OPENGL_INCLUDE_DIR})
    target_link_libraries(simpledump-ui PUBLIC ${OPENGL_LIBRARIES})
endif()

#GLFW3
if(MSVC)
    target_link_libraries(simpledump-ui PRIVATE glfw3dll.dll)
else()
    find_package(glfw3 CONFIG REQUIRED)
    target_link_libraries(simpledump-ui PRIVATE glfw)
endif()

if(MSVC OR BUILD_MSVC)
    install(TARGETS simpledump-ui DESTINATION ${CMAKE_INSTALL_BINDIR} RUNTIME_DEPENDENCY_SET satdump_deps)
else()
    install(TARGETS simpledump-ui DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
