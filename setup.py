# from distutils.core import setup
from setuptools import setup

setup(
    name='omop_etl',
    version='0.0.1',
    author='',
    author_email='yankuic@gmail.com',
    packages=['omop_etl'],
    entry_points={'console_scripts': ['omop_etl=omop_etl.cli:ETLCli']},
    url='',
    license='',
    description='',
    long_description=open('README.md').read(),
    # install_requires=[
    #     "pandas >= 0.25.1",
    #     "sqlalchemy >= 1.3.9",
    #     #"sqlparse >= 0.4.1",
    #     "pyyaml >= 5.1.2" 
    # ],
)
