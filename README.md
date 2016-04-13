LNP-shared-core
===============

[![Build Status](https://travis-ci.org/Lazy-Newb-Pack/LNP-shared-core.png?branch=master)](https://travis-ci.org/Lazy-Newb-Pack/LNP-shared-core)

Components of the Dwarf Fortress LNP that can be used on any OS.  
Contributions, feedback, and reuse all welcome.

The goal of this project is to create a canonical common base for different 
versions of the Lazy Newb Pack, across whatever platform or variant a user or 
pack maintainer feels like.  It assumes that the pack is based on the [PyLNP 
launcher](http://www.bay12forums.com/smf/index.php?topic=140808) or an 
equivalent, and content is currently targeted at DF v0.42.06 with DFHack.

It consists of alternative color schemes, standard 'newb friendly' default 
settings, an embark profile collection, keybindings (alternative control 
schemes), and miscellaneous "extras" to install.  

Components:
-----------

`LNP/colors`
------------
The color schemes come from a number of sources, including [Vherid's 
collection](http://www.bay12forums.com/smf/index.php?topic=89856).

`LNP/defaults`
--------------
Default settings to revert to.  The embarks are an install of 
`default_embarks.txt`.  The init files are for Phoebus with Twbt - so graphics 
should simply be reinstalled after resetting to defaults - with tweaks for new 
players by PeridexisErrant.  

`LNP/embarks`
-------------
The default profiles are sourced from [an appeal on Reddit](
http://redd.it/2ew1fa).  The starting scenarios are adapted from Masterwork Mod 
(for 34.11).  The advanced profiles are scraped [from the wiki](
http://dwarffortresswiki.org/index.php/DF2014:Embark_profile_repository) [2](
http://dwarffortresswiki.org/index.php/DF2014:Sample_Starting_Builds).  The 
tutorial profiles are from CaptnDuck and Mayday.  

`LNP/extras`
------------
The extras folder is copied into the DF install the first time the launcher is 
run.  The `/data/init` section installs the default init settings and 
keybinds.  The `/hack/scripts` section adds some dfhack scripts by Lethosor 
which are not yet included in standard DFHack:  [adv-max-skills, embark-skills, 
load-screen, manager-quantity, settings-manager, and title-version](
https://github.com/lethosor/dfhack-scripts).  We recently added 
`soundsense.lua` (extra announcements), and `burial.lua` by Putnam (configures 
all built coffins for burial).  Stocksettings are Rmblr's settings v2, [here](
http://dffd.wimbli.com/file.php?id=10170) based on [these](
http://redd.it/2o611s).

`LNP/keybinds`
--------------
The vanilla keybinds are copied from DF `0.40.23`.  The Classic LNP keybinds 
are adapted for laptop keyboards; PeridexisErrant ported the changes to a new 
version (from the discontinued Windows LNP).  The PeridexisErrant keybindings 
are additionally optimised for use with the mouse, eg with dfhack's mousequery 
plugin.

`LNP/mods`
--------------
Includes the [better item viewscreen](http://www.bay12forums.com/smf/index.php?topic=147707) raws, since they're a resource for the
included script.

`LNP/tilesets`
--------------
Some tilesets are from vanilla DF.  Fircy generated many more with mifki's 
[tileset generator](http://www.bay12forums.com/smf/index.php?topic=140250).  
`curses_24x24.png` is by [/u/dragonplatino](http://redd.it/2r8gtx).
