###########################################################################
# Copyright 2018,2019,2022 Konsulko Group
#
# Author: Scott Murray <scott.murray@konsulko.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###########################################################################

project(cluster-dashboard VERSION 2.0.0 LANGUAGES CXX)

if(CMAKE_VERSION VERSION_LESS "3.7.0")
    set(CMAKE_INCLUDE_CURRENT_DIR ON)
endif()
set(OE_QMAKE_PATH_EXTERNAL_HOST_BINS $ENV{OE_QMAKE_PATH_HOST_BINS})

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Gui QuickControls2 QuickWidgets REQUIRED)
find_package(Qt5Gui ${QT_MIN_VERSION} CONFIG REQUIRED Private)
find_package(PkgConfig REQUIRED)
find_program(WAYLAND_SCANNER_EXECUTABLE NAMES wayland-scanner)

qt5_add_resources(RESOURCES cluster-gauges.qrc images/images.qrc)

add_custom_command(
	OUTPUT  agl-shell-client-protocol.h
	COMMAND ${WAYLAND_SCANNER_EXECUTABLE} client-header
	< ${CMAKE_SOURCE_DIR}/app/protocol/agl-shell.xml
	> ${CMAKE_SOURCE_DIR}/app/agl-shell-client-protocol.h
	DEPENDS ${CMAKE_SOURCE_DIR}/app/protocol/agl-shell.xml
)

add_custom_command(
	OUTPUT  ${CMAKE_BINARY_DIR}/app/agl-shell-client-protocol.h
	COMMAND ${WAYLAND_SCANNER_EXECUTABLE} client-header
	< ${CMAKE_SOURCE_DIR}/app/protocol/agl-shell.xml
	> ${CMAKE_SOURCE_DIR}/app/agl-shell-client-protocol.h
	DEPENDS ${CMAKE_SOURCE_DIR}/app/protocol/agl-shell.xml
)

add_custom_command(
	OUTPUT  agl-shell-protocol.c
	COMMAND ${WAYLAND_SCANNER_EXECUTABLE} code
	< ${CMAKE_SOURCE_DIR}/app/protocol/agl-shell.xml
	> ${CMAKE_BINARY_DIR}/app/agl-shell-protocol.c
	DEPENDS ${CMAKE_SOURCE_DIR}/app/protocol/agl-shell.xml
)

add_executable(${PROJECT_NAME}
	main.cpp
	agl-shell-protocol.c
	agl-shell-client-protocol.h
	${RESOURCES}
)

pkg_check_modules(GLIB REQUIRED glib-2.0)
pkg_check_modules(WAYLAND_CLIENT REQUIRED wayland-client)

include_directories(
	include_directories(${Qt5Gui_PRIVATE_INCLUDE_DIRS})
	${QTAPPFW_INCLUDE_DIRS}
	${GLIB_INCLUDE_DIRS}
)

target_link_libraries(${PROJECT_NAME}
	Qt5::QuickControls2
	Qt5::QuickWidgets
	${QTAPPFW_LIBRARIES}
	${GLIB_LDFLAGS}
	${WAYLAND_CLIENT_LIBRARIES}
)

install(TARGETS ${PROJECT_NAME} DESTINATION bin)
