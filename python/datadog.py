# Make sure you replace the API and/or APP key below
# with the ones for your account
import initialize
import api
from datadog import initialize, api

options = {
    'api_key': 'd15bc0c919de4948552c9fd532b03620',
}

initialize(**options)

print api.Tag.get_all()
