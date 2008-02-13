def extract(fields, src):
    """Extracts the specified fields from each line
    in src.  Usage:

    >>> for record in extract(('rubrik', 'number', 'section'), '../2006-fall/BH2006FA.TXT'):
    >>>     print record['rubrik'], record['number'], record['section']
    ENGL 1301 2001
    ENGL 1301 2002
    ...
    """
    assert isinstance(src, (basestring, file))

    if isinstance(src, basestring):
        src = open(src)

    results = []
    for line in src:
        record = {}
        for field in fields:
            assert field in schema
            a,b = schema[field]
            record[field] = line[a:b].strip()
        results.append(record)

    src.close()
    return results


schema = {
    # real fields
    'year': (0, 4),
    'term': (4, 7),
    'campus': (7, 10),
    'rubrik': (10, 17),
    'number': (17, 24),
    'section': (24, 29),
    'synonym': (34, 45),
    'credit_hours': (45, 53),
    'division': (60, 64),
    'title': (64, 94),
    'faculty_0': (94, 124),
    'faculty_1': (124, 154),
    'faculty_2': (154, 184),
    'faculty_3': (184, 214),
    'faculty_4': (214, 244),
    'method_0': (244, 249),
    'method_1': (249, 254),
    'method_2': (254, 259),
    'method_3': (259, 264),
    'meets_0': (288, 321),
    'meets_1': (321, 354),
    'meets_2': (354, 387),
    'meets_3': (387, 420),
    'sessions': (420, 424),
    'begins': (424, 434),
    'ends': (434, 444),
    'type': (444, 449),
    'weeks': (449, 452),
    'topic_code': (477, 482),
    'comments_0': (482, 553),
    'comments_1': (553, 624),
    'comments_2': (624, 695),
    'comments_3': (695, 766),
    'comments_4': (766, 837),
    'comments_5': (837, 908),
    'comments_6': (908, 979),
    'comments_7': (979, 1050),
    'comments_8': (1050, 1121),
    'comments_9': (1121, 1192),
    'charges_0': (1919, 1936),
    'charges_1': (1936, 1953),
    'charges_2': (1953, 1970),
    'charges_3': (1970, 1987),
    'charges_total': (1987, 1999),
    'section_capacity': (2116, 2121),
    'cross_listings': (2004, 2116),

    # virtual fields
    'class_number': (0, 0),
    'class_sortkey': (0, 0),
    'subject': (0, 0),
    'subject_comments': (0, 0),
    'topic': (0, 0),
    'topic_comments': (0, 0),
    'topic_sortkey': (0, 0),
    'subtopic': (0, 0),
    'subtopic_comments': (0, 0),
    'subtopic_sortkey': (0, 0),
    'group': (0, 0),
    'course_sortkey': (0, 0),
    'minimester': (0, 0),
    'dates': (0, 0),
    'comments': (0, 0),
}
