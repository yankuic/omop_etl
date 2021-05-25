"""
Class template from: https://chase-seibert.github.io/blog/2014/03/21/python-multilevel-argparse.html
"""

import sys
import argparse

from omop_etl.load import Loader
from omop_etl.utils import timeitc

loader = Loader('config.yml')
MAPPING_TABLES = loader.mapping
PRELOAD_TABLES = loader.preload
LOAD_TABLES = loader.config.load
POSTPRO = loader.postproc

class ETLCli:

    def __init__(self):
        parser = argparse.ArgumentParser()
        usage='''Add instructions'''
        parser.add_argument('command', type=str, help='Enter command to run')
        args = parser.parse_args(sys.argv[1:2])

        if not hasattr(self, args.command):
            print('Unrecognized command')
            parser.print_help()
            exit(1)

        # use dispatch pattern to invoke method with same name
        getattr(self, args.command)()


    def archive(self):
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
                for t in LOAD_TABLES.keys():
                    print(loader.preload_all_subsets(t))


    def load(self):
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
