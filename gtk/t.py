#!/usr/bin/env python
# example base.py
import pygtk
pygtk.require('2.0')
import gtk
class Base:
	def __init__(self):
		self.window = gtk.Window(gtk.WINDOW_TOPLEVEL)
		self.window.set_default_size(1, gtk.gdk.screen_height())
		self.window.move(gtk.gdk.screen_width()-100, 0)
		self.window.set_type_hint(gtk.gdk.WINDOW_TYPE_HINT_NORMAL)
		self.window.show()
		self.window.window.property_change("_NET_WM_STRUT", "CARDINAL", 32, gtk.gdk.PROP_MODE_REPLACE, [0, 100, 0, 0]) 
	def main(self):
		gtk.main()
print __name__
if __name__ == "__main__":
	base = Base()
	base.main()

