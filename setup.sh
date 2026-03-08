#!/usr/bin/env bash
# ------------------------------------------------------------
# setup.sh – bootstrap a C++23 Vulkan/ImGui project on macOS (Apple Silicon)
# ------------------------------------------------------------

set -euo pipefail   # abort on error, treat unset vars as errors

# -----------------------------------------------------------------
# Ask for the project name
# -----------------------------------------------------------------
read -p "Enter your project name (no spaces, e.g. MyVulkanApp): " PROJECT_NAME
PROJECT_NAME=$(echo "$PROJECT_NAME" | xargs)   # trim whitespace

if [[ -z "$PROJECT_NAME" ]]; then
    echo "Project name cannot be empty."
    exit 1
fi

# -----------------------------------------------------------------
# Create the directory layout
# -----------------------------------------------------------------
BASE_DIR="$(pwd)/$PROJECT_NAME"

if [[ -d "$BASE_DIR" ]]; then
    read -p "⚠️ Directory '$BASE_DIR' already exists. Delete and continue? (y/N): " yn
    case $yn in
        [Yy]* ) rm -rf "$BASE_DIR";;
        * ) echo "Aborting."; exit 1;;
    esac
fi

mkdir -p "$BASE_DIR"/{src,external,build}
cd "$BASE_DIR"

# -----------------------------------------------------------------
# Initialise git and add the three submodules
# -----------------------------------------------------------------
git init

echo "Adding spdlog..."
git submodule add https://github.com/gabime/spdlog.git external/spdlog

echo "Adding GLFW..."
git submodule add https://github.com/glfw/glfw.git external/glfw

echo "Adding ImGui (docking branch)..."
git submodule add -b docking https://github.com/ocornut/imgui.git external/imgui

# Make sure the submodules are fetched completely
git submodule update --init --recursive

# -----------------------------------------------------------------
# Write a .gitignore (you can extend it later)
# -----------------------------------------------------------------
cat > .gitignore <<'EOF'
# Build artefacts -------------------------------------------------
/build/
/CMakeFiles/
CMakeCache.txt
cmake_install.cmake
install_manifest.txt
_compile_commands.json

# IDEs -----------------------------------------------------------
.idea/
.vscode/

# macOS ---------------------------------------------------------
.DS_Store

# Object / library files ------------------------------------------
*.o
*.obj
*.a
*.so
*.dylib
*.lib

# Misc -----------------------------------------------------------
*.log
EOF

# -----------------------------------------------------------------
# src/main.cpp (placeholder __PROJECT_NAME__ will be replaced)
# -----------------------------------------------------------------
cat > src/main.cpp <<'CPP'
#include <spdlog/spdlog.h>
#include <GLFW/glfw3.h>

#include "imgui.h"
#include "backends/imgui_impl_glfw.h"
#include "backends/imgui_impl_vulkan.h"

int main() {
    spdlog::info("Hello from __PROJECT_NAME__!");

    // -----------------------------------------------------------------
    // Initialise GLFW – we ask for a Vulkan surface, not an OpenGL context
    // -----------------------------------------------------------------
    if (!glfwInit()) {
        spdlog::error("Failed to initialise GLFW");
        return -1;
    }
    glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);
    GLFWwindow* window = glfwCreateWindow(1280, 720,
                                          "Vulkan + ImGui Demo",
                                          nullptr, nullptr);
    if (!window) {
        spdlog::error("Failed to create a GLFW window");
        glfwTerminate();
        return -1;
    }

    // -----------------------------------------------------------------
    // Initialise ImGui (only the back‑ends; real Vulkan init is omitted)
    // -----------------------------------------------------------------
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();

    ImGui_ImplGlfw_InitForVulkan(window, true);
    // NOTE: The actual VkInstance / swapchain setup would go here.

    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();               // <-- normally you'd start a new ImGui frame here
    }

    // -----------------------------------------------------------------
    // Clean‑up
    // -----------------------------------------------------------------
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();

    return 0;
}
CPP

# -----------------------------------------------------------------
# Top‑level CMakeLists.txt (placeholder __PROJECT_NAME__)
# -----------------------------------------------------------------
cat > CMakeLists.txt <<'CMAKE'
cmake_minimum_required(VERSION 3.24)

project(__PROJECT_NAME__ LANGUAGES CXX)

# ------------------------------------------------------------
# Use the C++23 language standard
# ------------------------------------------------------------
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# ------------------------------------------------------------
# Verify that the Vulkan SDK is installed (VULKAN_SDK env‑var must exist)
# ------------------------------------------------------------
if(NOT DEFINED ENV{VULKAN_SDK})
    message(FATAL_ERROR "VULKAN_SDK environment variable not set. Install the LunarG Vulkan SDK for macOS and source its setup script.")
endif()
list(APPEND CMAKE_PREFIX_PATH "$ENV{VULKAN_SDK}")

find_package(Vulkan REQUIRED)

# ------------------------------------------------------------
# External libraries (added as git submodules)
# ------------------------------------------------------------
add_subdirectory(external/spdlog)   
add_subdirectory(external/glfw)    

# ------------------------------------------------------------
# ImGui – build a static library from the sources + back‑ends
# ------------------------------------------------------------
set(IMGUI_DIR ${CMAKE_CURRENT_SOURCE_DIR}/external/imgui)

file(GLOB IMGUI_SOURCES
    ${IMGUI_DIR}/*.cpp
    ${IMGUI_DIR}/backends/imgui_impl_glfw.cpp
    ${IMGUI_DIR}/backends/imgui_impl_vulkan.cpp
)

add_library(imgui STATIC ${IMGUI_SOURCES})
target_include_directories(imgui PUBLIC
    ${IMGUI_DIR}
    ${IMIMGU_DIR}/backends   
)

target_include_directories(imgui PUBLIC
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
)

target_link_libraries(imgui PUBLIC glfw Vulkan::Vulkan)
target_compile_definitions(imgui PUBLIC VK_USE_PLATFORM_MACOS_MVK)

# ------------------------------------------------------------
# Main executable
# ------------------------------------------------------------
add_executable(${PROJECT_NAME} src/main.cpp)
target_link_libraries(${PROJECT_NAME}
    PRIVATE spdlog::spdlog imgui
)

# ------------------------------------------------------------
# macOS specific tweaks (none needed beyond the compile definition above)
# ------------------------------------------------------------
if(APPLE)
    # Nothing extra – CLion will automatically add required frameworks via GLFW
endif()
CMAKE

# -----------------------------------------------------------------
# Replace placeholder __PROJECT_NAME__ with the real name in both files
# -----------------------------------------------------------------
# BSD‑sed syntax used on macOS (`-i ''` means “in‑place, no backup”)
sed -i '' "s/__PROJECT_NAME__/${PROJECT_NAME}/g" CMakeLists.txt src/main.cpp

# -----------------------------------------------------------------
# Initial git commit
# -----------------------------------------------------------------
git add .
git commit -m "Initial skeleton for ${PROJECT_NAME} (C++23, Vulkan SDK check, spdlog + GLFW + ImGui‑Docking)"

# -----------------------------------------------------------------
# Done – launch CLion
# -----------------------------------------------------------------
echo "Project '${PROJECT_NAME}' has been created."
echo "Opening the project in CLion…"
open -a "CLion" .

