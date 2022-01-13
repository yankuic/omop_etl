#coding=utf-8

import sys
import threading
import time
import datetime
import logging
from contextlib import contextmanager
from functools import wraps
import re
#import numpy as np


def search(pattern, string, *args):
    """Return True if pattern is found in string."""
    try:
        if re.search(pattern, string, *args):
            return True
        else:
            return False

    except TypeError:
        return False


def find(pattern, values, ignore_case=True):  #not reviewed
    """Search pattern in list.
    
    Arguments:
        pattern {str, list} -- [description]
        values {list/array} -- List/array of strings.
    
    Returns:
        [numpy array] -- array

    """
    arg = None
    if ignore_case: 
        arg = re.IGNORECASE

    if isinstance(pattern, list):
        array = []
        for p in pattern:
            array.append(list(map(lambda x: search(p, x, arg), values)))
            # np.array(array)
        return np.max(array, 0)

    else:
        return np.array(list(map(lambda x: search(pattern, x, arg), values)))


@contextmanager
def timeitc(name=''):
    """Return elapsed time to run code block."""
    startTime = time.time()

    yield

    elapsedTime = time.time() - startTime
    print('{} finished in {}'.format(name, time.strftime("%H:%M:%S",  
                                     time.gmtime(elapsedTime))))

def timeitd(f):
    """Return elapsed time to run function."""
    @wraps(f)
    def wrap(*args, **kwargs):
        try: 
            arg = locals()['args'][1]
        except IndexError: 
            arg = ''

        try:
            kwarg = list(locals()['kwargs'].values())
        except IndexError:
            kwarg = ''
        
        msg = f"Executing {f.__name__}({arg}, {kwarg}) ... "

        def spinner():
            t = 0
            while True:
                timeformat = str(datetime.timedelta(seconds=t))
                sys.stdout.write(msg + timeformat + '\r')
                time.sleep(1)
                t += 1

                if done:
                    sys.stdout.write(msg + 'Done   ')
                    break 

        startTime = time.time()

        result = None

        try:
            done = False
            spin_thread = threading.Thread(target=spinner)
            spin_thread.start()

            result = f(*args, **kwargs)

            done = True
            spin_thread.join()

        except (KeyboardInterrupt, Exception):# AssertionError, SQLAlchemyError, AttributeError):
            done = True
            raise

        elapsedTime = time.time() - startTime

        logging.info(f'Process to execute {f.__name__}({arg}) is completed. Elapsed time: {time.strftime("%Hh:%Mm:%Ss", time.gmtime(elapsedTime))}')
        sys.stdout.write(f'\nElapsed time {time.strftime("%H:%M:%S", time.gmtime(elapsedTime))}\n')
        
        return (result or 0)

    return wrap

