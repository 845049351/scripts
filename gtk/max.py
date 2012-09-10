#!/usr/bin/env python
import sys
import gtk
import gtk.glade

if __name__ == '__main__':
	if len(sys.argv) > 1:
		fname = sys.argv[1]
	else:
		fname = 'mainwindow.glade'
	# create widget tree ...
	xml = gtk.glade.XML(fname)

def destroy(*args):
	print 'destroy'
	gtk.main_quit()

#xml.signal_connect('destroy', destroy)
window = xml.get_widget('mainWindow')
gtk.Window.maximize(window)
#gtk.Window.fullscreen(window)

gtk.main()

