Ceph Windows Installer
======================

This project generates a MSI installer for Ceph on Windows.

Requirements
------------

Visual Studio 2019 Community, Professional, Premium or Ultimate edition
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Visual Studio Community 2019 is freely available at:
https://www.visualstudio.com/en-us/products/visual-studio-community-vs.aspx

WiX Toolset 3.11
^^^^^^^^^^^^^^^^

Download and install from:
http://wixtoolset.org/releases/v3.11/stable

Copy the driver files built using the instructions from https://github.com/cloudbase/wnbd#how-to-build to the ``ceph-windows-installer/Driver`` folder.
Copy also the ``*.pdb`` files generated when building the driver in the ``ceph-windows-installer/Symbols`` folder. Optionally Ceph
symbols might be included as well. ``wnbd-client.exe`` as well as ``libwnbd.dll`` must be copied to the ``ceph-windows-installer/Binaries``
folder.

Copy the binaries built using the instructions from https://github.com/petrutlucian94/ceph/blob/windows.12/README.windows.rst#building
to the ``ceph-windows-installer/Binaries`` folder.

For the ceph-rbd service to work, additional steps are required after installation:

* Create the C:\\ProgramData folder. Inside, create a ceph.conf file with the required configuration (you can copy it from an osd server).
* Create a ceph.client.admin.keyring file with the required configuration (you can copy it from an osd server).
* Restart the service: :code:`Restart-Service ceph-rbd`

Build instructions
------------------

Build the solution in the Visual Studio IDE or via command line:
::

    msbuild ceph-windows-installer.sln /p:Platform=x64 /p:Configuration=Release

A complete build script that handles the Ceph and WNBD dependencies, plus the digital signature of both driver and MSI is also included.

To perform a full build with digital signature, using WSL for building Ceph:
::

    .\Build.ps1 -UseWSL`
    -SignX509Thumbprint 1234...`
    -SignCrossCertPath path\to\the\cross\cert.cer`
    -SignTimestampUrl http://timestampurl

To perform a full build with digital signature, copying the Ceph binaries from a separate location (can be a SSH, local or UNC path):
::

    .\Build.ps1 -CephZipPath user@host:ceph/build/ceph.zip`
    -SignX509Thumbprint 1234...`
    -SignCrossCertPath path\to\the\cross\cert.cer`
    -SignTimestampUrl http://timestampurl

By default, the dependencies build directory is removed before every build. To retain it, please use the ``-RetainDependenciesBuildDir`` argument.

To get a full list of the available command line arguments:
::

    help .\Build.ps1

Automated installation
----------------------

For automated deployments, this package can be installed with the standard MSI silent mode, for example:
::

    msiexec.exe /i Ceph.msi /l*v log.txt /qn
