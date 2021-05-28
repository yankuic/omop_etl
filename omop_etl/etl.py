"""
Class template from: https://chase-seibert.github.io/blog/2014/03/21/python-multilevel-argparse.html
"""

import sys
import os
import shutil
import argparse

import yaml

from omop_etl.load import Loader
from omop_etl.io import read_sql
from omop_etl.utils import timeitc

CONFIG_FILE = 'config.yml'

class ETLCli:

    def __init__(self):
        parser = argparse.ArgumentParser()
        usage = '''
        Add instructions here.
        '''
        parser.add_argument('command', type=str, help='Enter command to run')
        args = parser.parse_args(sys.argv[1:2])

        if not hasattr(self, args.command):
            print('Unrecognized command')
            parser.print_help()
            exit(1)

        # use dispatch pattern to invoke method with same name
        getattr(self, args.command)()


    def create_project_schema(self):
        #create omop tables and schemas
        loader = Loader(CONFIG_FILE)
        SCHEMA = loader.schema
        
        with timeitc('Creating project schema'):
            loader.create_schema('cohort')
            loader.create_schema('stage')
            loader.create_schema('results')

            for s in SCHEMA.keys():
                print(f'Creating schema {s}')
                script_file = os.path.join(loader.sql_scripts_path, SCHEMA[s])
                sqlstring = read_sql(script_file)
                print(loader.execute(sqlstring))

        #TODO: borrow achilles queries to validate schema here.


    def voc(self):
        #download vocabulary
        #load vocabulary into db
        raise NotImplementedError


    def new_project(self):
        #create project directory if not exists
        #copy template files into project directory
        #   -if server and db are specified save info into config.yml
        #   -save project name and project dir into config.yml
        #if server and db are specified ask if user wants to create project schema.
        parser = argparse.ArgumentParser('Create new OMOP project.')
        parser.add_argument('-p', '--path', type=str, help='Project directory', required=True)
        parser.add_argument('-n', '--name', type=str, help='Project name', required=True)
        parser.add_argument('-s', '--server', type=str, help='SQL Server URL')
        parser.add_argument('-db', '--database', type=str, help='Project database')

        args = parser.parse_args(sys.argv[2:])

        config_file = 'config.yml'
        dirname = os.path.dirname(os.path.abspath(__file__))
        template_path = os.path.join(dirname, 'templates')
        config_template_path = os.path.join(template_path, config_file)
        py_scripts = [f for f in os.listdir(template_path) if f.endswith('.py')]
        project_path = os.path.join(args.path, args.name)

        try:
            os.mkdir(project_path)
        except FileExistsError as e:
            raise e

        with open(config_template_path) as f:
            config = yaml.safe_load(f)

        config['project_info']['project_dir'] = project_path

        if args.server:
            config['db_connections']['omop']['server'] = args.server

        if args.database:
            config['db_connections']['omop']['database'] = args.database
        
        with open(os.path.join(project_path, config_file), 'w') as custom_config:
            yaml.dump(config, custom_config, sort_keys=False)

        for py in py_scripts:
            o = os.path.join(template_path, py)
            d = os.path.join(project_path, py)
            shutil.copyfile(o, d)

        print(f'New OMOP project created in {project_path}')


    def archive(self):
        loader = Loader(CONFIG_FILE)
        LOAD_TABLES = loader.config.load

        parser = argparse.ArgumentParser('Archive data tables from dbo schema.')
        parser.add_argument('-t', '--table', type=str, help='The table to archive')
        parser.add_argument('-a', '--all', help='Archive all tables.', action="store_true")

        args = parser.parse_args(sys.argv[2:])

        with timeitc('Archiving'):
            if args.table:
                t = args.table
                print(f'Archiving table {t}\n')
                print(loader.archive_table(t))

            elif args.all:
                for t in LOAD_TABLES.keys():
                    print(f'Archiving table {t}\n')
                    print(loader.archive_table(t))


    def postproc(self):
        loader = Loader(CONFIG_FILE)
        parser = argparse.ArgumentParser('Run postprocessing tasks.')
        parser.add_argument('--deid', help='Create HIPAA de-identified dataset', action="store_true")
        parser.add_argument('--limited', help='Create HIPAA limited dataset', action="store_true")
        parser.add_argument('--fix_domains', help='Move records to the appropiate domain tables.', action="store_true")

        args = parser.parse_args(sys.argv[2:])

        with timeitc("Postprocessing"):

            if args.deid:
                print(loader.load_hipaa())

            elif args.limited:
                print(loader.load_hipaa('limited'))

            elif args.fix_domains:
                print(loader.fix_domains())
        

    def stage(self):  
        loader = Loader(CONFIG_FILE)
        MAPPING_TABLES = loader.mapping
        LOAD_TABLES = loader.config.load

        parser = argparse.ArgumentParser('Stage data.')
        parser.add_argument('-t', '--table', type=str, help='The table to stage')
        parser.add_argument('-s', '--subset', type=str, help='If table has subsets pass this argument in combination with --table.')
        parser.add_argument('-a', '--all', help='Stage all tables.', action="store_true")

        args = parser.parse_args(sys.argv[2:])

        with timeitc("Staging"):
            if args.table:
                t = args.table
                sbs = args.subset
                if t in ('provider','care_site','location'): 
                    print(loader.stage_hs_table(t))
                else:
                    print(loader.stage_table(t, sbs or None ))

                if t in MAPPING_TABLES.keys():
                    print(f"Refreshing mappings for table {t}.")
                    print(loader.update_mapping_table(t))

            elif args.all:
                # stage all tables
                print("Staging all tables ...")
                for t in LOAD_TABLES.keys():
                    if isinstance(LOAD_TABLES[t], dict):
                        for part in LOAD_TABLES[t].keys():
                            print(loader.stage_table(t, part))
                            # print("Table with parts:", t, part)
                    else:
                        if t in ('provider','care_site','location'): 
                            print(loader.stage_hs_table(t))
                            # print("HS Table:", t)
                        else:
                            # print("Table with no parts:", t, LOAD_TABLES[t])
                            print(loader.stage_table(t))

                    # update mappings
                    if t in MAPPING_TABLES.keys():
                        print(f"Refreshing mappings for table {t}.")
                        print(loader.update_mapping_table(t))


    def preload(self):  
        loader = Loader(CONFIG_FILE)
        PRELOAD_TABLES = loader.preload

        parser = argparse.ArgumentParser('Preload tables.')
        parser.add_argument('-t', '--table', type=str, help='The table to preload.')
        parser.add_argument('-s', '--subset', type=str, help='If table has subsets pass this argument in combination with --table.')
        parser.add_argument('-a', '--all', help='Use this option to preload all tables.', action="store_true")

        args = parser.parse_args(sys.argv[2:])

        with timeitc("Preloading"):

            if args.table:
                t = args.table
                sbs = args.subset
                if sbs == 'all':
                    print(loader.preload_all_subsets(t))
                else:
                    print(loader.preload_table(t, sbs))

            elif args.all:
                # stage all tables
                print("Preloading all tables ...")
                for t in PRELOAD_TABLES.keys():
                    print(loader.preload_all_subsets(t))


    def load(self):
        loader = Loader(CONFIG_FILE)
        parser = argparse.ArgumentParser('Load data into OMOP tables.')
        parser.add_argument('-t', '--table', type=str, help='The table to load.')
        parser.add_argument('-a', '--all', help='Use this option to load all tables at once.', action="store_true")

        args = parser.parse_args(sys.argv[2:])

        with timeitc("Loading"):

            if args.table:
                t = args.table
                loader.truncate('dbo', t)
                print(loader.load_table(t))

            elif args.all:
                for t in loader.load.keys():
                    loader.truncate('dbo', t)
                    print(loader.load_table(t))
            

if __name__ == "__main__":
    ETLCli()
