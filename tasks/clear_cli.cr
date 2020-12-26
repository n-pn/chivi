require "../src/kernel/_models"
require "./migrate/*"

Clear::Migration::Manager.instance.apply_all
