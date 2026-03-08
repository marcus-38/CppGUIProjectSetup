A tiny **bootstrap script** that creates a complete C++23 project skeleton with:

| Feature | Library |
|---------|----------|
| Fast, header‑only logging | **spdlog** |
| Cross‑platform window & input (Vulkan surface) | **GLFW** |
| Immediate‑mode UI + docking support | **ImGui** *(docking branch)* |
| Build system that checks the Vulkan SDK is present | **CMake ≥ 3.24** |
| Ready‑to‑open in JetBrains **CLion** | — |

The script (`setup.sh`) does everything for you:

1. Prompts for a project name.  
2. Creates the directory layout (`src/`, `external/`, `build/`).  
3. Runs `git init` and adds the three libraries as **submodules**.  
4. Generates a minimal `main.cpp` that shows spdlog, GLFW and ImGui initialisation.  
5. Writes a top‑level `CMakeLists.txt` that:  
   * forces **C++ 23**,  
   * aborts if `$VULKAN_SDK` is not defined,  
   * builds the submodules and links them together.  
6. Commits everything and launches **CLion** on the new folder.

After the first build you have a working “Hello‑World” Vulkan‑compatible program that you can immediately extend.

---

## Table of Contents
- [Prerequisites](#prerequisites)
- [Quick Start (One‑Liner)](#quick-start-one-liner)
- [Step‑by‑Step Walkthrough](#step-by-step-walkthrough)
  - [1️⃣ Clone / download the script](#1️⃣-clone--download-the-script)
  - [2️⃣ Make it executable & run it](#2️⃣-make-it-executable--run-it)
  - [3️⃣ Set up the Vulkan SDK (macOS only)](#3️⃣-set-up-the-vulkan-sdk-macos-only)
  - [4️⃣ Build in CLion](#4️⃣-build-in-clion)
- [Project Layout Explained](#project-layout-explained)
- [Updating Submodules / Adding New Dependencies](#updating-submodules--adding-new-dependencies)
- [Customising the CMakeLists.txt](#customising-the-cmakeliststxt)
- [Common Issues & Troubleshooting](#common-issues--troubleshooting)
- [License](#license)

---

## Prerequisites

| Tool | Minimum version | Why it’s needed |
|------|-----------------|-----------------|
| **macOS** (Apple Silicon – e.g. M1/M2) | 12.0+ | Native ARM support |
| **Xcode Command Line Tools** (`xcode-select --install`) | any | Provides `clang` and the system SDK |
| **Git** | 2.30+ | Submodule handling |
| **CMake** | 3.24+ | Required for modern C++23 features & target‑linking syntax |
| **Vulkan SDK for macOS** (LunarG) | latest | Supplies headers, libraries and the `VULKAN_SDK` env‑var |
| **CLion** (optional but recommended) | 2023.2+ | IDE integration – the script opens the project automatically |

> **Tip:** After installing the Vulkan SDK, add the following line to your shell profile (`~/.zshrc`, `~/.bash_profile`, …) so that the variable is always available:

```bash
export VULKAN_SDK="/Users/$(whoami)/VulkanSDK/<VERSION>"
```

Replace `<VERSION>` with the folder name created by the installer (e.g. `1.3.283.0`). Then run `source ~/.zshrc` (or open a new terminal).

---

## Quick Start (One‑Liner)

```bash
# 1️⃣ Grab the script
curl -Ls https://raw.githubusercontent.com/yourusername/vulkan-imgui-cmake-starter/main/setup.sh -o setup.sh

# 2️⃣ Make it executable & run it
chmod +x setup.sh && ./setup.sh    # follow the prompt for a project name
```

The script will:

* create `<ProjectName>/`
* pull spdlog, GLFW and ImGui (docking branch) as submodules,
* generate `CMakeLists.txt` and a tiny demo source file,
* open CLion on the new folder.

Now press **⌘ ⇧ B** in CLion → *Build Project*. 🎉

---

## Step‑by‑Step Walkthrough

### 1️⃣ Clone / download the script
You can either:

```bash
git clone https://github.com/yourusername/vulkan-imgui-cmake-starter.git
cd vulkan-imgui-cmake-starter
```

or just fetch the single file with `curl` as shown above.

---

### 2️⃣ Make it executable & run it

```bash
chmod +x setup.sh          # only needed once
./setup.sh                 # you’ll be asked for a project name
```

**Example interaction**

```
Enter your project name (no spaces, e.g. MyVulkanApp): AwesomeDemo
Adding spdlog...
Adding GLFW...
Adding ImGui (docking branch)...
Project 'AwesomeDemo' has been created.
Opening the project in CLion…
```

If a folder with that name already exists the script will ask whether to delete it.

---

### 3️⃣ Set up the Vulkan SDK (macOS only)

1. Download **Vulkan SDK for macOS** from <https://vulkan.lunarg.com/sdk/home>  
2. Run the installer – it places the files under `~/VulkanSDK/<VERSION>` and prints a line you can copy:

   ```bash
   export VULKAN_SDK=~/VulkanSDK/1.3.283.0
   ```

3. Add that line to your shell startup file (`~/.zshrc` or `~/.bash_profile`) and reload the terminal.

> **CMake will abort with a clear error if `$VULKAN_SDK` is missing**, so make sure this step is done before you try to build.

---

### 4️⃣ Build in CLion

* The script automatically launches CLion (`open -a "CLion" .`).  
* In CLion: **Build → Build Project** (or press `⌘ ⇧ B`).  

You should see something like:

```
[100%] Linking CXX executable AwesomeDemo
Build finished successfully.
```

Run the binary (`Run → Run 'AwesomeDemo'`) – a window titled *“Vulkan + ImGui Demo”* will appear, and the console prints:

```
[info] Hello from AwesomeDemo!
```

> The demo only creates an empty GLFW window and initialises ImGui; you’ll need to add Vulkan swap‑chain code and UI widgets yourself. See the official ImGui docking example for a quick start.

---

## 📁 Project Layout Explained

```
AwesomeDemo/
├─ .git/                     ← git repository
├─ .gitignore                ← ignores build artefacts, IDE files, etc.
├─ CMakeLists.txt            ← top‑level build description (C++23, Vulkan check)
├─ src/
│   └─ main.cpp              ← minimal demo (spdlog + GLFW + ImGui init)
├─ external/                 ← submodule folder
│   ├─ spdlog/               ← git submodule → https://github.com/gabime/spdlog.git
│   ├─ glfw/                 ← git submodule → https://github.com/glfw/glfw.git
│   └─ imgui/                ← git submodule (branch: docking)
├─ build/                    ← out‑of‑source build folder (CLion uses this by default)
└─ README.md                 ← you are reading it now
```

*All external libraries live under `external/` and are version‑controlled as **git submodules**. This makes the repository lightweight – only the pointers are stored, not the full library sources.*

---

## 🔄 Updating Submodules / Adding New Dependencies

### Update existing ones
```bash
cd AwesomeDemo
git submodule update --remote --merge   # fetch latest commits from upstream
git add external/*                      # stage changes
git commit -m "Update spdlog, glfw and imgui to newest revisions"
```

### Add a new library (example: GLM)
```bash
git submodule add https://github.com/g-truc/glm.git external/glm
# Edit CMakeLists.txt:
#   add_subdirectory(external/glm)  # or just target_include_directories(...)
git add external/glm CMakeLists.txt
git commit -m "Add GLM as a header‑only dependency"
```

---

## Customising the `CMakeLists.txt`

| What you might want to change | Where & how |
|------------------------------|-------------|
| **Use shared libraries** for spdlog or glfw | Edit their submodule CMake options before adding them: <br>`set(SPDLOG_BUILD_SHARED ON CACHE BOOL "" FORCE)`<br>`add_subdirectory(external/spdlog)` |
| **Add a custom include directory** (e.g. `include/`) | Add `target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)` after the `add_executable` line. |
| **Enable extra compiler warnings** | Insert `target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -pedantic)` (AppleClang supports these flags). |
| **Link additional frameworks** (e.g. Metal) | Add `target_link_libraries(${PROJECT_NAME} PRIVATE "-framework Metal")`. |
| **Change the output binary name** | Modify `project(__PROJECT_NAME__ LANGUAGES CXX)` → `set(PROJECT_BINARY_NAME "MyApp")` and use `${PROJECT_BINARY_NAME}` wherever the executable target appears. |

The script already contains a *minimal* but functional CMake configuration that you can extend safely – just keep the **Vulkan SDK check** block intact.

---

## Common Issues & Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `CMake Error: VULKAN_SDK environment variable not set` | Vulkan SDK not installed or `$VULKAN_SDK` missing from the shell that CLion launches. | Ensure you added `export VULKAN_SDK=…` to your login shell configuration and **restart** CLion (or launch it from a terminal where the variable is defined). |
| `Undefined symbols for architecture arm64: _vkCreateInstance` | The MoltenVK library isn’t linked. | Verify that `$VULKAN_SDK/lib` contains `libMoltenVK.dylib`. CMake should automatically link it via `find_package(Vulkan REQUIRED)`. If not, add:<br>`target_link_libraries(${PROJECT_NAME} PRIVATE "${VULKAN_SDK}/lib/libMoltenVK.dylib")`. |
| Build fails with “`-std=c++2b` is not recognized” | Compiler does not support C++23. | Apple Clang from Xcode 15+ supports it. If you’re on an older toolchain, install a newer LLVM (`brew install llvm`) and point CLion to that compiler (Preferences → Toolchains). |
| Submodule directories are empty after cloning the repo | You forgot `git submodule update --init --recursive`. | Run the command inside the project root or re‑run the script. |
| `GLFW` complains about missing X11 on macOS | The wrong platform flag is being used. | Ensure that `glfwWindowHint(GLFW_CLIENT_API, GLFW_NO_API);` stays in `main.cpp`. The CMake file already sets `Vulkan::Vulkan`, which pulls MoltenVK. |
| ImGui docking UI not showing | You haven’t created a dockspace or any windows yet. | Follow the official ImGui docking example (`examples/example_docking_main.cpp`) and copy the relevant code into your render loop. |

If you encounter something else, feel free to open an issue on the repository – include the full CMake output and `clang++ --version`.

---

## License

```text
MIT License

Copyright (c) 2026 marcus@r38.se

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[… standard MIT text …]
```

The bootstrap script itself (`setup.sh`) and this `README.md` are released under the **MIT License**. The external libraries (spdlog, GLFW, ImGui) keep their original licenses – see each submodule’s `LICENSE` file.

---
