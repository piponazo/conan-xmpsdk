from conans import ConanFile, CMake, tools
import shutil


class XmpsdkConan(ConanFile):
    name = "XmpSdk"
    version = "2016.7"
    license = "The BSD License"
    url = "https://github.com/piponazo/conan-xmpsdk"
    description = "<Description of Xmpsdk here>"
    settings = "os", "compiler", "build_type", "arch"
    exports = ["CMake/*", "third-party/*", "FindXmpSdk.cmake"]

    options = {"shared": [True, False]}
    default_options = "shared=False"

    generators = "cmake"

    # TODO: Require uuid-dev on Linux

    def source(self):
        tools.get('http://download.macromedia.com/pub/developer/xmp/sdk/XMP-Toolkit-SDK-CC201607.zip')

    def build(self):
        shutil.copyfile(src="CMake/CMakeLists.txt", dst="XMP-Toolkit-SDK-CC201607/CMakeLists.txt")
        shutil.copyfile(src="CMake/XMPCore/CMakeLists.txt", dst="XMP-Toolkit-SDK-CC201607/XMPCore/CMakeLists.txt")
        shutil.copytree(src="CMake/cmake", dst="XMP-Toolkit-SDK-CC201607/cmake")

        shutil.rmtree("XMP-Toolkit-SDK-CC201607/third-party/expat")
        shutil.copytree(src="third-party/expat", dst="XMP-Toolkit-SDK-CC201607/third-party/expat")

        # BUILD_SHARED_LIBS defined with self.shared value
        cmake = CMake(self)
        cmake.configure(source_folder="XMP-Toolkit-SDK-CC201607")
        cmake.build()

    def package(self):
        self.copy("FindXmpSdk.cmake")
        self.copy("*", dst="include", src="XMP-Toolkit-SDK-CC201607/public/include")
        self.copy("*.h", dst="include", src="XMP-Toolkit-SDK-CC201607/third-party/zuid/interfaces")
        self.copy("*.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["XMPCore"]
        self.cpp_info.includedirs = ['include']  # Ordered list of include paths
        self.cpp_info.libdirs = ['lib']  # Directories where libraries can be found
        self.cpp_info.resdirs = ['res']  # Directories where resources, data, etc can be found
        self.cpp_info.bindirs = ['bin']  # Directories where executables and shared libs can be found
        # TODO MAC_ENV || UNIX_ENV || WIN_ENV || IOS_ENV
        self.cpp_info.defines = []  # preprocessor definitions
        self.cpp_info.cflags = []  # pure C flags
        self.cpp_info.cppflags = []  # C++ compilation flags
        self.cpp_info.sharedlinkflags = []  # linker flags
        self.cpp_info.exelinkflags = []  # linker flags

