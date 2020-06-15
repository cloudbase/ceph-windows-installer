Ceph Windows Installer
==============================

This project generates a MSI installer for Ceph on Windows.

Requirements
------------

Visual Studio 2019 Community, Professional, Premium or Ultimate edition
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Visual Studio Community 2019 is freely available at:
https://www.visualstudio.com/en-us/products/visual-studio-community-vs.aspx

WiX Toolset 3.11
^^^^^^^^^^^^^^^

Download and install from:
http://wixtoolset.org/releases/v3.11/stable

Build instructions
------------------

Build the solution in the Visual Studio IDE or via command line:
   
    msbuild ceph-windows-installer.sln /p:Platform=x86 /p:Configuration=Release
