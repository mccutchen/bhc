import inspect, sys

def get_valid_profiles(objectdict, base, required_attrs):
    # put each valid profile into a dictionary keyed
    # on its name
    return dict(
        [(key, value)
         for key,value in objectdict.items()
         if is_valid_profile(value, base, required_attrs)]
    )

def is_valid_profile(obj, base, required_attrs):
    """Is this a valid profile?"""
    try:
        assert inspect.isclass(obj) and issubclass(obj, base)
        for attr in required_attrs:
            assert hasattr(obj, attr), 'Valid profiles must have the `%s` attribute set' % attr
            assert getattr(obj, attr, None) is not None, 'Valid profiles cannot have the `%s` attribute == None' % attr
    except AssertionError:
        return False

    # all tests passed
    return True

def find_profile(name, profiles):
    name = name.lower()
    for key in profiles:
        if key.lower() == name:
            return profiles[key]
    return None

def choose_profile(profiles, invalid=False, given=''):
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
            choose_profile(profiles, True, raw_profile)
        else:
            return real_profile

    except EOFError:
        import sys
        sys.exit(1)

def list_profiles(profiles):
    names = profiles.keys()
    names.sort()
    print 'Valid profiles:'
    print ' ',
    print '\n  '.join(names)

def get_profile(profiles):
    try:
        profilename = sys.argv[1]
        profile = find_profile(profilename, profiles)
        if profile is None:
            return choose_profile(profiles, True, sys.argv[1])
        else:
            print 'Using profile %s' % profile
            return profile
    except IndexError:
        return choose_profile(profiles)
