#coding: utf-8
__version__ = "0.0.1"

# Let users know if they're missing any of our hard and optional dependencies
hard_dependencies = ("pandas", "sqlparse", "sqlalchemy", "yaml")
optional_dependencies = ("turbodbc", "selenium")
missing_dependencies = []


for dependency in hard_dependencies:
    try:
        __import__(dependency)
        
    except ImportError as e:
        missing_dependencies.append(f"{dependency}: {e}")

if missing_dependencies:
    raise ImportError(
        "Unable to import required dependencies:\n" + "\n".join(missing_dependencies)
    )
del hard_dependencies, dependency


for dependency in optional_dependencies:
    try:
        __import__(dependency)
        
    except ImportError as e:
        missing_dependencies.append(f"{dependency}: {e}")

if missing_dependencies:
    print(
        "Unable to import optional dependencies:\n" + "\n".join(missing_dependencies)
    )
    pass
del optional_dependencies, dependency, missing_dependencies


# from omop_etl.load import Loader

# try:
#     from omop_etl.io import to_csv
# except ImportError as e:
#     logging.warning(
#         "Unable to import module to_csv"
#     )
#     pass
