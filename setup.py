# from distutils.core import setup
from setuptools import setup

setup(
    name='omop_etl',
    version='0.1',
    author='Yankuic Galvan',
    author_email='yankuic@gmail.com',
    packages=['omop_etl'],
    package_dir={'omop_etl': 'omop_etl'},
    package_data={
        'omop_etl': ['sql/*.sql','chrome/chromedriver.exe', 'templates/*'],
    },
    data_files=[('omop_etl', ['omop_etl/etl_config.yml'])],
    entry_points={
        'console_scripts': ['omop_etl=omop_etl.cli:ETLCli']
    },
    url='',
    license='',
    description='',
    long_description=open('README.md').read(),
    # install_requires=[
    #     "pandas",
    #     "sqlalchemy",
    #     "sqlparse",
    #     "pyodbc",
    #     "pyyaml" 
    # ],
)
