import os, sys
from wrm import sxml
from wrm.utils import apdate, copyfiles
import settings, xmlbuilder

def build(xmldoc):
    print >> settings.log.info, 'Starting to build staff directory...'
    
    # make sure the output directory exists
    outdir = settings.output.directory
    if not os.path.exists(outdir):
        print >> settings.log.info, ' - Creating directory to hold output: %s' % outdir
        os.makedirs(outdir)
    
    params = {'date': '"%s"' % apdate()}
    transformer = sxml.transformer(xmldoc.getroot(), settings.templates.xsl, 'alphagroup', 'letter', params)
    for name, output in transformer:
        outfile = get_outfile(name)
        print >> settings.log.info, ' - Writing letter %s' % name
        outfile.write(output)
    
    print >> settings.log.info, 'Finished.'


def postbuild():
    """
    Copies any extras defined in settings over to the
    output directory.
    """
    try:
        print >> settings.log.info, '\nCopying extra files...',
        copyfiles(settings.extras.sourcedir, settings.output.directory, settings.extras.patterns)
        print >> settings.log.info, 'Finished.'
    except AttributeError:
        pass
    except IOError, e:
        print >> settings.log.info, '\n ! Could not copy extra files: %s' % e


def get_outpath(letter):
    localpath = settings.output.html.prefix + letter.lower() + settings.output.html.suffix
    return os.path.join(settings.output.directory, localpath)
def get_outfile(letter, mode='w'):
    return file(get_outpath(letter), mode)


###############
# Main method #
###############
def main():
    xmldoc = xmlbuilder.build()
    build(xmldoc)
    postbuild()
    
    # wait for some input from the user and quit
    raw_input('\nPress return to exit.')
    sys.exit(0)

if __name__ == '__main__':
    main()