
class TRCData(dict):

    def load(self, filename):

        header_read_successfully = False
        labels = []
        with open(filename) as f:
            contents = f.readlines()
            line_count = 0
            for line in contents:
                line_count += 1
                line = line.strip()
                if line_count == 1:
                    # File Header 1
                    sections = line.split('\t')
                    self[sections[0]] = sections[1]
                    self['DataFormat'] = sections[2]
                    data_format_count = len(sections[2].split('/'))
                    self['FileName'] = sections[3]
                elif line_count == 2:
                    # File Header 2
                    file_header_keys = line.split('\t')
                elif line_count == 3:
                    # File Header 3
                    file_header_data = line.split('\t')
                    if len(file_header_keys) == len(file_header_data):
                        for index, key in enumerate(file_header_keys):
                            if key == 'Units':
                                self[key] = file_header_data[index]
                            else:
                                self[key] = float(file_header_data[index])
                    else:
                        raise IOError('File format invalid: File header keys count (%d) is not equal to file header data count (%d)' % (len(file_header_keys), len(file_header_data)))
                elif line_count == 4:
                    # Data Header 1
                    data_header_labels = line.split('\t')
                    if data_header_labels[0] != 'Frame#':
                        raise IOError('File format not valid data header does not start with "Frame#".')
                    if data_header_labels[1] != 'Time':
                        raise IOError('File format not valid data header in position 2 is not "Time".')

                    self['Frame#'] = []
                    self['Time'] = []
                elif line_count == 5:
                    # Data Header 1
                    data_header_sublabels = line.split('\t')
                    if len(data_header_labels) != len(data_header_sublabels):
                        raise IOError('File format invalid: Data header labels count (%d) is not equal to data header sub-labels count (%d)' % (len(data_header_labels), len(data_header_sublabels)))

                    labels = []
                    for label in data_header_labels:
                        label = label.strip()
                        if len(label):
                            self[label] = []
                            labels.append(label)

                    self['Labels'] = labels
                elif line_count == 6 and len(line) == 0:
                    # Blank line
                    header_read_successfully = True
                else:
                    # Some files don't have a blank line at line six
                    if line_count == 6:
                        header_read_successfully = True
                    # Data section
                    if header_read_successfully:
                        sections = line.split('\t')

                        frame = int(sections.pop(0))
                        self['Frame#'].append(frame)

                        time = float(sections.pop(0))
                        self['Time'].append(time)

                        len_section = len(sections)
                        if len_section % data_format_count == 0:
                            data = [[float(sections[subindex]) for subindex in range(index, index + data_format_count)] for index in range(0, len_section, data_format_count)]
                            self[frame] = (time, data)

                            for index, label_data in enumerate(data):
                                # Add two to the index as we want to skip 'Frame#' and 'Time'
                                self[labels[index + 2]] += [label_data]

                        else:
                            raise IOError('File format invalid: data frame %d does not match the data format' % len_section)

# #!/usr/bin/env python
# '''This creates an app to launch a python script. The app is
# created in the directory where python is called. A version of Python
# is created via a softlink, named to match the app, which means that
# the name of the app rather than Python shows up as the name in the
# menu bar, etc, but this requires locating an app version of Python
# (expected name .../Resources/Python.app/Contents/MacOS/Python in
# directory tree of calling python interpreter).
#
# Run this script with one or two arguments:
#     <python script>
#     <project name>
# The script path may be specified relative to the current path or given
# an absolute path, but will be accessed via an absolute path. If the
# project name is not specified, it will be taken from the root name of
# the script.
# '''
# import sys, os, os.path, stat
# def Usage():
#     print("\n\tUsage: python "+sys.argv[0]+" <python script> [<project name>]\n")
#     sys.exit()
#
# version = "1.0.0"
# bundleIdentifier = "org.test.test"
#
# if not 2 <= len(sys.argv) <= 3:
#     Usage()
#
# script = os.path.abspath(sys.argv[1])
# if not os.path.exists(script):
#     print("\nFile "+script+" not found")
#     Usage()
# if os.path.splitext(script)[1].lower() != '.py':
#     print("\nScript "+script+" does not have extension .py")
#     Usage()
#
# if len(sys.argv) == 3:
#     project = sys.argv[2]
# else:
#     project = os.path.splitext(os.path.split(script)[1])[0]
#
# # find the python application; must be an OS X app
# pythonpath,top = os.path.split(os.path.realpath(sys.executable))
# while top:
#     if 'Resources' in pythonpath:
#         pass
#     elif os.path.exists(os.path.join(pythonpath,'Resources')):
#         break
#     pythonpath,top = os.path.split(pythonpath)
# else:
#     print("\nSorry, failed to find a Resources directory associated with "+str(sys.executable))
#     sys.exit()
# pythonapp = os.path.join(pythonpath,'Resources','Python.app','Contents','MacOS','Python')
# if not os.path.exists(pythonapp):
#     print("\nSorry, failed to find a Python app in "+str(pythonapp))
#     sys.exit()
#
# apppath = os.path.abspath(os.path.join('.',project+".app"))
# newpython =  os.path.join(apppath,"Contents","MacOS",project)
# projectversion = project + " " + version
# if os.path.exists(apppath):
#     print("\nSorry, an app named "+project+" exists in this location ("+str(apppath)+")")
#     sys.exit()
#
# os.makedirs(os.path.join(apppath,"Contents","MacOS"))
#
# f = open(os.path.join(apppath,"Contents","Info.plist"), "w")
# f.write('''<?xml version="1.0" encoding="UTF-8"?>
# <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
# <plist version="1.0">
# <dict>
#     <key>CFBundleDevelopmentRegion</key>
#     <string>English</string>
#     <key>CFBundleExecutable</key>
#     <string>main.sh</string>
#     <key>CFBundleGetInfoString</key>
#     <string>{:}</string>
#     <key>CFBundleIconFile</key>
#     <string>app.icns</string>
#     <key>CFBundleIdentifier</key>
#     <string>{:}</string>
#     <key>CFBundleInfoDictionaryVersion</key>
#     <string>6.0</string>
#     <key>CFBundleName</key>
#     <string>{:}</string>
#     <key>CFBundlePackageType</key>
#     <string>APPL</string>
#     <key>CFBundleShortVersionString</key>
#     <string>{:}</string>
#     <key>CFBundleSignature</key>
#     <string>????</string>
#     <key>CFBundleVersion</key>
#     <string>{:}</string>
#     <key>NSAppleScriptEnabled</key>
#     <string>YES</string>
#     <key>NSMainNibFile</key>
#     <string>MainMenu</string>
#     <key>NSPrincipalClass</key>
#     <string>NSApplication</string>
# </dict>
# </plist>
# '''.format(projectversion, bundleIdentifier, project, projectversion, version)
#     )
# f.close()
#
# # not sure what this file does
# f = open(os.path.join(apppath,'Contents','PkgInfo'), "w")
# f.write("APPL????")
# f.close()
# # create a link to the python app, but named to match the project
# os.symlink(pythonapp,newpython)
# # create a script that launches python with the requested app
# shell = os.path.join(apppath,"Contents","MacOS","main.sh")
# # create a short shell script
# f = open(shell, "w")
# f.write('#!/bin/sh\nexec "'+newpython+'" "'+script+'"\n')
# f.close()
# os.chmod(shell, os.stat(shell).st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
