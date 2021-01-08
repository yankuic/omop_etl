#coding=utf-8

import time
from contextlib import contextmanager

@contextmanager
def timeitc(name=''):
    """Return elapsed time to run a code block."""
    startTime = time.time()

    yield

    elapsedTime = time.time() - startTime
    print('{} finished in {}'.format(name, time.strftime("%H h %M m %S s",  
                                     time.gmtime(elapsedTime))))
