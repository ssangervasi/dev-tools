"""Example Package Setup"""

__copyright__ = ''
__author__ = 'Sebastian Sangervasi'

import os

from setuptools import find_packages, setup

with open(os.path.join(os.path.dirname(__file__), 'README.md')) as readme:
    README = readme.read()

# Allow setup.py to be run from any path
os.chdir(os.path.normpath(os.path.join(os.path.abspath(__file__), os.pardir)))

setup(
    name='example',
    version='0.1',
    packages=find_packages(),
    include_package_data=False,
    description='An example package. Do not use me!',
    long_description=README,
    license=__copyright__,
    url='',
    author=__author__,
    author_email='sebastian@ditto.com',
    classifiers=[
        'Intended Audience :: Developers',
        'Operating System :: OS Independent',
        'Programming Language :: Python',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.7',
    ],
)
