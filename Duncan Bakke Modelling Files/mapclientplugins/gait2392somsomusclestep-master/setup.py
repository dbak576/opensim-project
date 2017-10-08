from setuptools import setup, find_packages
import sys, os, io

# List all of your Python package dependencies in the
# requirements.txt file

def readfile(filename):
    with io.open(filename, encoding="utf-8") as stream:
        return stream.read().split("\n")

readme = readfile("README.rst")[3:]  # skip title
requires = readfile("requirements.txt")
license = readfile("LICENSE")

setup(name=u'mapclientplugins.gait2392somsomusclestep',
      version='0.1',
      description='',
      long_description=readme + license,
      classifiers=[],
      author=u'Ju Zhang',
      author_email='',
      url='',
      license='APACHE',
      packages=find_packages(exclude=['ez_setup',]),
      namespace_packages=['mapclientplugins'],
      include_package_data=True,
      zip_safe=False,
      install_requires=requires,
      )
