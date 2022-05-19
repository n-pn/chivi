# About Application.cr File
#
# This is Amber application main entry point. This file is responsible for loading
# initializers, classes, and all application related code in order to have
# Amber::Server boot up.
#
# > We recommend not modifying the order of the requires since the order will
# affect the behavior of the application.

require "amber"
require "./settings"
require "./logger"
require "./database"
require "./initializers/**"

# Start Generator Dependencies: Don't modify.
require "../src/appcv/**"
# End Generator Dependencies

require "../src/webcv/pipes/**"
require "../src/webcv/views/**"
require "../src/webcv/forms/**"
require "../src/webcv/ctrls/shared/*"
require "../src/webcv/ctrls/**"

require "./routes"
