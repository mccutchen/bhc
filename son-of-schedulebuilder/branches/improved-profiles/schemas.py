from wrm.schema import *
from formatters import *


# We have to define a special schema for each session because of the
# way the data is separated in the Colleague schedule download.
# Ideally, this would all be taken care of by a simple sub-Schema.
# Each of these schemas is formatted using a
# formatters.SessionFormatter.
session_schema_1 = Schema(SessionFormatter(),
    Field('faculty-name', 94, 124),
    VirtualField('faculty-last-name'),
    VirtualField('faculty-first-initial'),
    Field('method', 244, 249),
    Field('building', 288, 292),
    Field('room', 292, 300),
    Field('start-time', 300, 307),
    Field('end-time', 307, 314),
    VirtualField('formatted-times'),
    Field('days', 314, 321),
)
session_schema_2 = Schema(SessionFormatter(),
    Field('faculty-name', 124, 154),
    VirtualField('faculty-last-name'),
    VirtualField('faculty-first-initial'),
    Field('method', 249, 254),
    Field('building', 321, 325),
    Field('room', 325, 333),
    Field('start-time', 333, 340),
    Field('end-time', 340, 347),
    VirtualField('formatted-times'),
    Field('days', 347, 354),
)
session_schema_3 = Schema(SessionFormatter(),
    Field('faculty-name', 154, 184),
    VirtualField('faculty-last-name'),
    VirtualField('faculty-first-initial'),
    Field('method', 254, 259),
    Field('building', 354, 358),
    Field('room', 358, 366),
    Field('start-time', 366, 373),
    Field('end-time', 373, 380),
    VirtualField('formatted-times'),
    Field('days', 380, 387),
)
session_schema_4 = Schema(SessionFormatter(),
    Field('faculty-name', 184, 214),
    VirtualField('faculty-last-name'),
    VirtualField('faculty-first-initial'),
    Field('method', 259, 264),
    Field('building', 387, 391),
    Field('room', 391, 399),
    Field('start-time', 399, 406),
    Field('end-time', 406, 413),
    VirtualField('formatted-times'),
    Field('days', 413, 420),
)


# This is the main schema for the Colleague schedule download file.
# It uses the schemas defined above to parse out the four possible
# class sessions.  This schema is formatted using a
# formatters.CreditFormatter.
schema = Schema(CreditFormatter(),
    Field('year', 0, 4),
    Field('term', 4, 7),
    VirtualField('term-sortkey'),
    VirtualField('term-dates'),
    Field('campus', 7, 10),
    Field('rubrik', 10, 17),
    Field('number', 17, 24),
    Field('section', 24, 29),
    Field('synonym', 34, 45),
    Field('credit-hours', 45, 53),
    Field('division', 60, 64),
    Field('title', 64, 94),
    DumbSchemaField('session', session_schema_1),
    FieldSet('extra-sessions',
        DumbSchemaField(None, session_schema_2),
        DumbSchemaField(None, session_schema_3),
        DumbSchemaField(None, session_schema_4),
    ),
    Field('classroom-sessions', 420, 424),
    Field('start-date', 424, 434),
    Field('end-date', 434, 444),
    VirtualField('formatted-dates'),
    Field('type', 444, 449),
    Field('weeks', 449, 452),
    Field('topic-code', 477, 482),
    FieldSet('comments',
        AnonymousField(482, 553),
        AnonymousField(553, 624),
        AnonymousField(624, 695),
        AnonymousField(695, 766),
        AnonymousField(766, 837),
        AnonymousField(837, 908),
        AnonymousField(908, 979),
        AnonymousField(979, 1050),
        AnonymousField(1050, 1121),
        AnonymousField(1121, 1192),
    ),
    FieldSet('charges',
        AnonymousField(1919, 1936),
        AnonymousField(1936, 1953),
        AnonymousField(1953, 1970),
        AnonymousField(1970, 1987),
    ),
    Field('charges-total', 1987, 1999),
    FieldSet('cross-listings',
        AnonymousField(2004, 2018),
        AnonymousField(2018, 2032),
        AnonymousField(2032, 2046),
        AnonymousField(2046, 2060),
        AnonymousField(2060, 2074),
        AnonymousField(2074, 2088),
        AnonymousField(2088, 2102),
        AnonymousField(2102, 2116),
    ),
    Field('section-capacity', 2116, 2121),
    VirtualField('class-number'),
    VirtualField('class-sortkey'),
    VirtualField('class-sortkey-date'),
    VirtualField('class-sortkey-time'),
    VirtualField('subject-name'),
    VirtualField('subject-comments'),
    VirtualField('subject-sortkey'),
    VirtualField('topic-name'),
    VirtualField('topic-comments'),
    VirtualField('topic-sortkey'),
    VirtualField('subtopic-name'),
    VirtualField('subtopic-comments'),
    VirtualField('subtopic-sortkey'),
    VirtualField('special-cross-listings'),
    VirtualField('course-sortkey'),
    VirtualField('minimester'),
    VirtualField('minimester-sortkey'),
    VirtualField('core-component'),
)