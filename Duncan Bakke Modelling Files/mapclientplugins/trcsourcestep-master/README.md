TRC Source Step
===============
The TRC source step is a plugin for the MAP Client that will read in
a TRC data file and create a dictionary from the data stored within 
the file.

Requires
--------
- MAP Client: https://github.com/MusculoskeletalAtlasProject/mapclient

Inputs
------
None

Outputs
-------
- **trcdata** [dict] - A dictionary containing the TRC file data. The
key/value pairs are:
    - 'PathFileType' : Path file type
    - 'DataFormat' : Format of marker data, e.g. '(X/Y/Z)'
    - 'FileName' : Original filename of the TRC file
    - 'Frame#' : List of frame numbers
    - 'Time' : List of frame timestamps
    - 'Labels' : List of marker names
    - frame [int] : a list of the time and marker coordinates of that frame
    
Configuration
-------------
- **identifier** : Unique name for the step.
- **Location** : Path of the TRC file to be read.

Usage
-----
Configure the step with the file path of the TRC file to be read. On
execution, the step will output the data of the TRC file in a dict. 
Can be output to TRC Frame Selector Step to select a specific frame.

