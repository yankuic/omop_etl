from distutils.core import setup

setup(
    name='omop_etl',
    version='0.1',
    author='',
    author_email='',
    packages=['omop_etl'],
    scripts=['bin/run_etl.py'],
    url='',
    license='',
    description='',
    long_description=open('README.md').read(),
    install_requires=[
        "pandas >= 0.25.1",
        "sqlalchemy == 1.3.9",
        "sqlparse == 0.4.1"
    ],
)
