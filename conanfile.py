from conans import ConanFile, CMake, tools
import shutil
import os

class XmpsdkConan(ConanFile):
    name = "XmpSdk"
    version = "2016.7"
    license = "The BSD License"
    url = "https://github.com/piponazo/conan-xmpsdk"
    description = "<Description of Xmpsdk here>"
    settings = "os", "compiler", "build_type", "arch"
    exports = ["CMake/*", "third-party/*", "FindXmpSdk.cmake", "MD5.patch"]

    generators = "cmake"
    short_paths = True

    def system_requirements(self):
        if tools.os_info.is_linux:
            installer = tools.SystemPackageTool()
            installer.install('uuid-dev')

    def configure(self):
        del self.settings.compiler.libcxx

    def source(self):
        tools.get('http://download.macromedia.com/pub/developer/xmp/sdk/XMP-Toolkit-SDK-CC201607.zip')

    def build(self):
        shutil.copyfile(src="CMake/CMakeLists.txt", dst="XMP-Toolkit-SDK-CC201607/CMakeLists.txt")
        shutil.copyfile(src="CMake/XMPCore/CMakeLists.txt", dst="XMP-Toolkit-SDK-CC201607/XMPCore/CMakeLists.txt")
        shutil.copytree(src="CMake/cmake", dst="XMP-Toolkit-SDK-CC201607/cmake")

        shutil.rmtree("XMP-Toolkit-SDK-CC201607/third-party/expat")
        shutil.copytree(src="third-party/expat", dst="XMP-Toolkit-SDK-CC201607/third-party/expat")

        # It has been always compiled as a STATIC library within the Exiv2 project.
        # In SHARED mode it has problems on windows, since they are not exporting some symbols
        # properly.
        cmake_args = {"BUILD_SHARED_LIBS": "OFF",
                     }
        generator_arg = None

        if tools.os_info.is_macos:
            cmake_args.update({"XMP_OSX_SDK": os.environ["XMP_OSX_SDK"],
                               "CMAKE_XCODE_ATTRIBUTE_GCC_VERSION": "com.apple.compilers.llvm.clang.1_0"
                              })
            generator_arg = 'Xcode'

        cmake = CMake(self, generator=generator_arg)
        cmake.verbose = True
        cmake.configure(source_folder="XMP-Toolkit-SDK-CC201607", args=cmake_args)
        cmake.build()

        tools.patch(base_path="XMP-Toolkit-SDK-CC201607/third-party/zuid/interfaces",
                    patch_file="MD5.patch")

    def package(self):
        self.copy("FindXmpSdk.cmake")
        self.copy("*", dst="include", src="XMP-Toolkit-SDK-CC201607/public/include")
        self.copy("*.h", dst="include", src="XMP-Toolkit-SDK-CC201607/third-party/zuid/interfaces")
        self.copy("*.lib", dst="lib", keep_path=False,
                  excludes="XMP-Toolkit-SDK-CC201607/XMPFilesPlugins/*")
        self.copy("*.dll", dst="bin", keep_path=False,
                  excludes="XMP-Toolkit-SDK-CC201607/XMPFilesPlugins/*")
        self.copy("*.so", dst="lib", keep_path=False,
                  excludes="XMP-Toolkit-SDK-CC201607/XMPFilesPlugins/*")
        self.copy("*.dylib", dst="lib", keep_path=False,
                  excludes="XMP-Toolkit-SDK-CC201607/XMPFilesPlugins/*")
        self.copy("*.a", src="lib", dst="lib", keep_path=False,
                  excludes="XMP-Toolkit-SDK-CC201607/XMPFilesPlugins/*")

    def package_info(self):
        self.cpp_info.libs = ["XMPCore"]
        self.cpp_info.includedirs = ['include']  # Ordered list of include paths
        self.cpp_info.libdirs = ['lib']  # Directories where libraries can be found
        self.cpp_info.resdirs = ['res']  # Directories where resources, data, etc can be found
        self.cpp_info.bindirs = ['bin']  # Directories where executables and shared libs can be found
        if tools.os_info.is_windows:
            self.cpp_info.defines = ['WIN_ENV']
        elif tools.os_info.is_macos:
            self.cpp_info.defines = ['MAC_ENV']
        else:
            self.cpp_info.defines = ['UNIX_ENV']
        self.cpp_info.cflags = []  # pure C flags
        self.cpp_info.cppflags = []  # C++ compilation flags
        self.cpp_info.sharedlinkflags = []  # linker flags
        self.cpp_info.exelinkflags = []  # linker flags

