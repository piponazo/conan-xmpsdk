from conan.packager import ConanMultiPackager


if __name__ == "__main__":
    builder = ConanMultiPackager(archs=['x86_64'], build_types=['Release'])
    builder.add_common_builds(shared_option_name="XmpSdk:shared")
    builder.run()
