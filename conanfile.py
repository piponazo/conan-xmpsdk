from conans import ConanFile, CMake, tools
import shutil


class XmpsdkConan(ConanFile):
    name = "XmpSdk"
    version = "2016.7"
    license = "The BSD License"
    url = "https://github.com/piponazo/conan-xmpsdk"
    description = "<Description of Xmpsdk here>"
    settings = "os", "compiler", "build_type", "arch"
    exports = ["CMake/*", "third-party/*"]

    options = {"shared": [True, False]}
    default_options = "shared=False"

    generators = "cmake"

    def source(self):
        tools.get('http://download.macromedia.com/pub/developer/xmp/sdk/XMP-Toolkit-SDK-CC201607.zip')

    def build(self):
        shutil.copyfile(src="CMake/CMakeLists.txt", dst="XMP-Toolkit-SDK-CC201607/CMakeLists.txt")
        shutil.copyfile(src="CMake/XMPCore/CMakeLists.txt", dst="XMP-Toolkit-SDK-CC201607/XMPCore/CMakeLists.txt")
        shutil.copytree(src="CMake/cmake", dst="XMP-Toolkit-SDK-CC201607/cmake")

        shutil.rmtree("XMP-Toolkit-SDK-CC201607/third-party/expat")
        shutil.copytree(src="third-party/expat", dst="XMP-Toolkit-SDK-CC201607/third-party/expat")

        cmake = CMake(self)
        cmake.configure(source_folder="XMP-Toolkit-SDK-CC201607")
        cmake.build()

    def package(self):
        self.copy("*.h", dst="include", src="hello")
        self.copy("*.lib", dst="lib", keep_path=False)
        self.copy("*.dll", dst="bin", keep_path=False)
        self.copy("*.so", dst="lib", keep_path=False)
        self.copy("*.dylib", dst="lib", keep_path=False)
        self.copy("*.a", dst="lib", keep_path=False)

    def package_info(self):
        self.cpp_info.libs = ["hello"]

