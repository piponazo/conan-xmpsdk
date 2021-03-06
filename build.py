from conan.packager import ConanMultiPackager


if __name__ == "__main__":
    builder = ConanMultiPackager(archs=['x86_64'], build_types=['Release'],
                                visual_runtimes=['MD'])
    builder.add_common_builds(pure_c=False)
    builder.run()
