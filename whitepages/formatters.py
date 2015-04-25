from wrm.formatter import Formatter
import settings

class WhitePagesFormatter(Formatter):
    
    def default_formatter(self, data):
        if isinstance(data, basestring):
            return data.strip()
        return data
    
    def format_PhotoPath(self, data):
        if isinstance(data, basestring):
            return settings.portraits_location + data.strip()
        return None
    
    def format_Room(self, data):
        try:
            data = data.strip()
            if data[0] in string.letters and data[1] in string.digits:
                return 'Room %s' % data
        except: pass
        return data