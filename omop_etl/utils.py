#coding=utf-8

import time
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
        startTime = time.time()
        result = f(*args, **kwargs)
        elapsedTime = time.time() - startTime
        print(f'{f.__name__} complete. Elapsed time {time.strftime("%H:%M:%S", time.gmtime(elapsedTime))}')
        return result
    return wrap
