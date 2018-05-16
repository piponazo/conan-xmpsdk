cmake_minimum_required(VERSION 2.8.12)
project(PackageTest CXX)

include(${CMAKE_BINARY_DIR}/conanbuildinfo.cmake)
conan_basic_setup()

find_package(XmpSdk REQUIRED)

add_executable(example example.cpp)
target_link_libraries(example PRIVATE ${XMPSDK_LIBRARIES})
target_include_directories(example PRIVATE ${XMPSDK_INCLUDE_DIRS})
target_compile_definitions(example PRIVATE ${XMPSDK_DEFINES})
