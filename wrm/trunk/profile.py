import inspect, sys

def get_profile(objectdict, base, validator=lambda x: True):
    """Given a dict of objects (as returned from `globals()`) and a
    base class that all profiles must inherit from, this function will
    try to get a profile name from the command line or, failing that,
    by prompting the user.
    
    If the validator function is given, it will be called on the
    chosen profile, and may raise exceptions explaining the problem
    with the profile."""
    profiles = get_profiles(objectdict, base)
    try:
        profilename = sys.argv[1]
        profile = find_profile(profilename, profiles)
        
        # invalid profile name given at the command line, so inform
        # the user of their error and prompt for another name
        if profile is None:
            profile = choose_profile(profiles, invalid=True, given=sys.argv[1])
        
    except IndexError:
        # We didn't get a profile name at the command line, so
        # we just prompt for one
        profile = choose_profile(profiles)
    
    # run the validator function on the chosen profile
    validator(profile)
    
    # we've got a valid profile, let's use it!
    print 'Using profile %s' % profile
    return profile

def get_profiles(objectdict, base):
    """Returns a list of the objects in objectdict which are
    subclasses of the given base class.  Should be a list of
    profile classes, given an appropriate base class."""
    return dict(
        [(key, value)
         for key,value in objectdict.items()
         if is_profile(value, base)]
    )

def is_profile(obj, base):
    """Is this a valid profile?"""
    return inspect.isclass(obj) and issubclass(obj, base)

def find_profile(name, profiles):
    """Does a case-insensitive search of the given list of
    profiles for one that matches the given name."""
    name = name.lower()
    for key in profiles:
        if key.lower() == name:
            return profiles[key]
    return None

def choose_profile(profiles, invalid=False, given=''):
    """Prompts the user to choose a profile at the command
    line.  Will optionally display a list of available profiles."""
    try:
        message = '\nType "?" to see a list of profiles or "exit" to exit.\n\nProfile to run: '
        if invalid:
            message = '\nError: Invalid profile given (%s)\n%s' % (given, message[1:])

        raw_profile = raw_input(message)
        profile = raw_profile.lower()

        if profile in ('exit', 'quit', 'q'):
            import sys
            sys.exit(0)

        if profile in ('', 'help', '?'):
            list_profiles(profiles)
            return choose_profile(profiles)

        real_profile = find_profile(profile, profiles)

        if real_profile is None:
            return choose_profile(profiles, True, raw_profile)
        else:
            return real_profile

    except EOFError:
        import sys
        sys.exit(1)

def list_profiles(profiles):
    """Prints a list of available profiles."""
    names = profiles.keys()
    names.sort()
    print 'Valid profiles:'
    print ' ',
    print '\n  '.join(names)
