LNP-shared-core
===============

Components of the Dwarf Fortress LNP that can be used on any OS.

The goal of this project is to create a canonical common base for different versions of the Lazy Newb Pack, across whatever platform or variant a user or pack maintainer feels like.  It assumes that the pack is based on the [PyLNP launcher]() or an equivalent, and content is currently targeted at DF v0.40.16

It consists of alternative color schemes, standard 'newb friendly' default settings, an embark profile collection, keybindings (alternative control schemes), and miscellaneous "extras" to install.  

As a work in progress, be aware that it's not finished yet and may have odd or conflicting settings!

Contributions, feedback, and reuse all welcome.

TODO:  continue documenting sources of components.

Components:
-----------

`LNP/colors`
------------
The color schemes come from a number of sources, including [Vherid's collection](http://www.bay12forums.com/smf/index.php?topic=89856).

`LNP/defaults`
--------------
Default settings to revert to.  The embarks are an install of `default_embarks.txt`.  The init files are for Phoebus with Twbt - so graphics should simply be reinstalled after resetting to defaults - with tweaks for new players by PeridexisErrant.  

`LNP/embarks`
-------------
The default profiles are sourced from [an appeal on Reddit]().  The starting scenarios are adapted from Masterwork Mod (for 34.11).  The advanced profiles are scraped [from the wiki](http://dwarffortresswiki.org/index.php/DF2014:Embark_profile_repository) [2](http://dwarffortresswiki.org/index.php/DF2014:Sample_Starting_Builds).  The tutorial profiles are from CaptnDuck and Mayday.  

`LNP/extras`
------------
The extras folder is copied into the DF install the first time the launcher is run.  The `/data/init` section installs the default init settings and keybinds.  The `/hack/scripts` section adds some dfhack scripts by Putnam and Lethosor:  [gaydar](https://gist.github.com/Putnam3145/77492ae79ca54fbf8af3), [adv-max-skills, load-screen, manager-quantity, settings-manager, and title-version](https://github.com/lethosor/dfhack-scripts).

`LNP/keybinds`
--------------
The vanilla keybinds are copied from DF `0.40.14`.  The Classic LNP keybinds are adapted for laptop keyboards; PeridexisErrant ported the changes to a new version (from the discontinued Windows LNP).  The PeridexisErrant keybindings are additionally optimised for use with the mouse, eg with dfhack's mousequery plugin.
