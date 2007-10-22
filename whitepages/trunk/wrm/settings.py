# settings.py
# $Id: settings.py 859 2005-04-27 15:08:26Z wrm2110 $

import ConfigParser
import decorators

config = ConfigParser.SafeConfigParser()

@decorators.cached
def get(section, option=None, typefunc=None):
    try:
        section = section.strip()
        if option: option = option.strip()
        else: return config.has_section(section)
        
        if not typefunc: return config.get(section, option)
        elif typefunc is int: return config.getint(section, option)
        elif typefunc is bool: return config.getboolean(section, option)
        elif typefunc is float: return config.getfloat(section, option)
        else: return typefunc(config.get(section, option))

    except ConfigParser.NoOptionError:
        try:
            return config.get(section, 'default')
        except ConfigParser.NoOptionError:
            return None
    except ConfigParser.NoSectionError:
        return None

@decorators.cached
def keys(section='DEFAULT'):
    return [key for key, value in config.items(section)]

@decorators.cached
def items(section='DEFAULT'):
    return config.items(section)

@decorators.cached
def sections():
    return config.sections()

@decorators.cached
def set(section, option, value):
    config.set(section, option, value)