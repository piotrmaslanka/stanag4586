import os

from satella.files import read_lines
from setuptools import find_packages
from distutils.core import setup
from snakehouse import build, Multibuild, monkey_patch_parallel_compilation, find_pyx

monkey_patch_parallel_compilation()


build_kwargs = {}
directives = {'language_level': '3'}
dont_snakehouse = False
if 'DEBUG' in os.environ:
    dont_snakehouse = True
    build_kwargs.update(gdb_debug=True)
    directives['embedsignature'] = True


setup(name='stanag4586',
      version='0.1a1',
      description='A library for parsing STANAG 4586 communications',
      author='Piotr Maślanka',
      author_email='piotr.maslanka@dronehub.ai',
      packages=find_packages(include=['stanag4586', 'stanag4586.*']),
      install_requires=[line for line in read_lines('requirements.txt') if not line.startswith('git+https')],
      ext_modules=build([Multibuild('stanag4586', find_pyx('stanag4586'),
                                    dont_snakehouse=dont_snakehouse)],
                        compiler_directives=directives, **build_kwargs),
      python_requires='!=2.7.*,!=3.0.*,!=3.1.*,!=3.2.*,!=3.3.*,!=3.4.*,!=3.5.*,!=3.6.*,!=3.7.*',
      zip_safe=False
      )
