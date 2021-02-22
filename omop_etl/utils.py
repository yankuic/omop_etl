#coding=utf-8

import sys
import threading
import time
import logging
from contextlib import contextmanager
from functools import wraps

@contextmanager
def timeitc(name=''):
    """Return elapsed time to run code block."""
    startTime = time.time()

    yield

    elapsedTime = time.time() - startTime
    print('{} finished. Elapsed time {}'.format(name, time.strftime("%H:%M:%S",  
                                     time.gmtime(elapsedTime))))

def timeitd(f):
    """Return elapsed time to run function."""
    @wraps(f)
    def wrap(*args, **kwargs):
        arg = locals()['args'][1]
        print(f"Executing {f.__name__}({arg}) ... ", end='')

        def spinner():
            while True:
                for cursor in '|/-\\':
                    sys.stdout.write(cursor)
                    sys.stdout.flush()
                    time.sleep(0.1)
                    sys.stdout.write('\b')
                    if done:
                        sys.stdout.write('Done')
                        return

        startTime = time.time()

        result = None

        try:
            done = False
            spin_thread = threading.Thread(target=spinner)
            spin_thread.start()

            result = f(*args, **kwargs)

            done = True
            spin_thread.join()

        except (KeyboardInterrupt, AssertionError):
            done = True
            raise

        elapsedTime = time.time() - startTime

        logging.info(f'Process to execute {f.__name__}({arg}) is completed. Elapsed time: {time.strftime("%Hh:%Mm:%Ss", time.gmtime(elapsedTime))}')
        sys.stdout.write(f'\nElapsed time {time.strftime("%H:%M:%S", time.gmtime(elapsedTime))}\n')
        
        return (result or 0)

    return wrap

