trcframeselectorstep
====================
MAP client plugin for getting landmark coordinates from a specific frame
of TRC motion capture data.

Requires
--------
- NumPy
- MAP Client: https://github.com/MusculoskeletalAtlasProject/mapclient

Inputs
------
- **trcdata** [dict] - dictionary of data from a TRC file. Can be output
by TRC Source Step.
- **integer** [int][optional] - The frame from which to output marker coordinates

Outputs
-------
- **landmarks** [dict]: Dictionary of {marker_name : marker_coordinates} at
the specified frame.

Configuration
-------------
- **identifier** : Unique name for the step.
- **Frame** : The frame from which to output marker coordinates.
    
Usage
-----
This step is intended to be used the TRC Source Step to extract the marker
names and coordinates at a specific frame. The frame must be provided by the
user either through the configuration or as an input in the second input port.
If an integer if provided via the port, the configured frame number will be
ignored.


