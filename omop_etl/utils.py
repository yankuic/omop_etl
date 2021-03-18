#coding=utf-8

import sys
import threading
import time
import datetime
import logging
from contextlib import contextmanager
from functools import wraps

from sqlalchemy.exc import SQLAlchemyError

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

        except (KeyboardInterrupt, AssertionError, SQLAlchemyError):
            done = True
            raise

        elapsedTime = time.time() - startTime

        logging.info(f'Process to execute {f.__name__}({arg}) is completed. Elapsed time: {time.strftime("%Hh:%Mm:%Ss", time.gmtime(elapsedTime))}')
        sys.stdout.write(f'\nElapsed time {time.strftime("%H:%M:%S", time.gmtime(elapsedTime))}\n')
        
        return (result or 0)

    return wrap

