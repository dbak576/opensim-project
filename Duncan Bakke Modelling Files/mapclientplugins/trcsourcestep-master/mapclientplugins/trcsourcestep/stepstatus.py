
class StepStatus(object):

    def __init__(self):
        self._identifier = 'trcsource'
        self._location = ''

    def location(self):
        return self._location

    def identifier(self):
        return self._identifier

    def setLocation(self, location):
        self._location = location

    def setIdentifier(self, identifier):
        self._identifier = identifier
