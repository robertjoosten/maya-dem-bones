from skbuild import setup

setup(
    packages=["dem_bones"],
    package_dir={"": "src"},
    cmake_install_dir="src/dem_bones",
)
