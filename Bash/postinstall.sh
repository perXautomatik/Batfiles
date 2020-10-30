#!/bin/bash
################################################################################
#                             postinstall.sh                                   #
#                                                                              #
# A BASH script to run YUM and install some additional administratively        #
# useful tools, fonts, applications and other stuff. This script is intended   #
# for use with Fedora 16 and above and CentOS 6.0 and above.                   #
#                                                                              #
# This script is installed by the postinstall RPM package. It is intended      #
# to be run after that installation. It could be run stand-alone but some      #
# things may not work.                                                         #
#                                                                              #
#                               Changelog                                      #
#   Date      Who      Description                                             #
#-----------  -------- --------------------------------------------------------#
# 2009/09/28  dboth    Initial code created from part of the %post section of  #
#                      davidsutils RPM. Performs some configuration and        #
#                      installs some useful RPM packages using YUM that could  #
#                      not be done from within the davidsutils RPM.            #
# 2011/12/31  dboth    Added font cache update to postinstall.sh after         #
#                      installing long list of fonts.                          #
# 2012/01/01  dboth    Extracted the postinstall.sh script from the %post      #
#                      install section of the RPM and added it as a separate   #
#                      file to be installed.                                   #
# 2012/01/04  dboth    Added code to postinstall.sh to modify grub.conf to     #
#                      display GRUB menu for 10 seconds and to remove rhgb.    #
# 2012/01/31  dboth    Rewrote postinstall.sh to use options for desktop or    #
#                      server hosts.                                           #
#                      Desktop now installs many GUI fonts.                    #
#                      Added code to postinstall.sh to check for kdebase and   #
#                      install the "KDE software compilation" if it is not.    #
# 2012/04/06  dboth    Configures localhost and Google for DNS and starts      #
#                      the caching nameserver.                                 #
# 2012/05/01  dboth    Add iftop to admin tools installation.                  #
# 2012/05/14  dboth    Moved NTP configuration to postinstall.sh from the RPM  #
#                      because it may need to be installed, and configuration  #
#                      is more complex with chkconfig and systemctl both being #
#                      possibilities.                                          #
#                      Changed mc Midnight Commander configuration to handle   #
#                      new configuration file locations. Place files in        #
#                      temporary location during installation of the RPM.      #
#                      Added reboot option.                                    #
# 2012/05/19  dboth    Moved /etc/bashrc configuration items from the RPM to   #
#                      this script. Includes alias for lsn and set CLI         #
#                      editing mode to Vi.                                     #
# 2012/05/30  dboth    Added multimedia and application options to install     #
#                      more of the applications that are in Fedora Frog.       #
# 2012/05/31  dboth    Cleaned up code and created new RPM installation        #
#                      subroutine since the code was used in so many places.   #
# 2012/07/26  dboth    Added code to postinstall.sh to install the             #
#                      compat-libstdc++-33 library. Added code to add my email #
#                      address to the end of /etc/aliases and run the          #
#                      newaliases command.                                     #
# 2012/07/28  dboth    Added ALL option to install Desktop, Multimedia, Server,#
#                      Applications and Development packages. Changed code to  #
#                      install iptraf-ng intead of iptraf which is obsolete.   #
#                      Changed code to install all lists of RPMs passed to the #
#                      InstallRPMList() function as a single list rather than  #
#                      breaking it up into individual RPMs for passing to YUM. #
#                      Because the Fedora Fusion rpositories no longer support #
#                      releases prior to Fedora 15, added a check that         #
#                      prevents postinstall.sh from running in any prior       #
#                      release.                                                #
# 2012/07/29  dboth    Minor changes to clean up small issues.                 #
# 2012/08/01  dboth    Add Centos compatibility.                               #
# 2012/08/06  dboth    Added .toprc to files installed for root and misc       #
#                      bug fixes.                                              #
# 2012/11/02  dboth    Add to postinstall.sh: ATRPMs repo and installation of  #
#                      the DVD playback libraries.                             #
# 2012/11/30  dboth    Added installation of Kaffeine multimedia player.       #
# 2012/11/30  dboth    Move code to add my destination address for root in     #
#                      /etc/aliases out of server section and into section     #
#                      where it will always be added.                          #
# 2012/12/10  dboth    Corrected grep for NIC onboot=yes to include yes in     #
#                      quotes using egrep.                                     #
# 2012/12/11  dboth    Modified logic for appending aliases and vi mode to     #
#                      /etc/bashrc to only add comments if alias needs added.  #
# 2012/12/15  dboth    Created a separate procedure DoDavidsStuff for those    #
#                      tasks that are to be done only on my own systems. This  #
#                      is a "hidden" option and does not appear in the help    #
#                      and is NOT part of the A option. It is Option Q.        #
# 2012/12/18  dboth    Added code to DoDavidsStuff procedure to disable and    #
#                      turn of the firstboot service.                          #
# 2012/12/19  dboth    Split some DoDavidsStuff procedure tasks into a new     #
#                      "DoClassroom" procedure. These tasks are done for the   #
#                      classroom hosts as well as my own personal hosts. The   #
#                      DoDavidsStuff tasks are NOT done for the classroom. An  #
#                      installation for the classroom uses options -vdcr.      #
#                      Removed vim from packages to install as it already is.  #
#                      Add code to create user "student" with the password     #
#                      "lockout" for classroom hosts.                          #
# 2012/12/21  dboth    Add code to DoDavidsStuff procedure to add user dboth   #
#                      and encrypted password.                                 #
# 2012/12/22  dboth    Adjust logic around doing davids and classroom stuff.   #
# 2012/12/25  dboth    Remove the big font installation from the desktop part  #
#                      to make the desktop all about KDE.                      #
# 2013/01/03  dboth    Move Adobe repo installation to Desktop section. Ensure #
#                      that no graphical stuff in DoDavidsStuff proc so that   #
#                      it can be used on CLI only systems. Added DoDavidsStuff #
#                      to help.                                                #
# 2013/01/05  dboth    Added correct email address for root in /etc/aliases.   #
# 2013/01/06  dboth    Moved code to add detail level 10 to Logwatch so that   #
#                      it is not added when classroom=1.                       #
# 2013/01/09  dboth    Move code to add /etc/LogBanner for SSH server from     #
#                      %post script to postinstall.sh. Added to section to     #
#                      add only if NOT a student host. Move MOTD code to       #
#                      postinstall.sh as well. Move code to disable first boot #
#                      so that it is always executed.                          #
# 2013/01/10  dboth    Change Desktop option to KDE and move applications from #
#                      that option into the "applications" option. Minor logic #
#                      fixes.                                                  #
# 2013/01/16  dboth    Install wget early if not present already.              #
# 2013/01/18  dboth    Add code to install other desktops such as Xfce, LXDE,  #
#                      Cinnamon, Sugar, etc. Also revamp code for KDE to work  #
#                      with the group name change in F18. Fedora 16 is now the #
#                      minimum level supported due to lack of repositories for #
#                      earlier releases.                                       #
# 2013/01/22  dboth    Add code to install LibreOffice.                        #
#                      Made this a major version increment to 3.0.0.0 due to   #
#                      the significant changes in both logic and packages      #
#                      installed.                                              #
# 2013/02/02  dboth    Remove redundant InstallRPMList call after call to      #
#                      installAdobeRepo. Also added code to null the $RPMlist  #
#                      variable after installing RPMs.                         #
#                      Disabled installation of old codecs.                    #
# 2013/02/02  dboth    Fork postinstall.sh from this code.                     #
# 2013/02/14  dboth    Added check 64-bit architecture.                        #
# 2013/02/15  dboth    Use architecture info to install 32 or 64 bit version   #
#                      of Adobe Flash.                                         #
# 2013/02/21  dboth    Revised  64-bit architecture check to look at kernel.   #
# 2013/02/23  dboth    Added additional message when performing tasks for my   #
#                      own hosts.                                              #
#                      Add switchdesk and krusader to desktop applications to  #
#                      install.                                                #
# 2013/02/26  dboth    Install the KDM Display Manager and make it default.    #
#                      This saves CPU cycles due to the window shade           #
#                      animation of GDM.                                       #
# 2013/03/19  dboth    Add option to install all desktops.                     #
# 2013/03/20  dboth    Rewind to use postinstall.sh code and then add in       #
#                      the code for David's stuff. This takes advantage of the #
#                      very nicely redone logic in postinstall.sh.             #
# 2013/03/21  dboth    Converted -c option to -t and -T options for Intro and  #
#                      Advanced training class options.                        #
# 2013/03/22  dboth    Added check for mutually exclusive T and t options.     #
# 2013/03/23  dboth    Separate code to create a student user and add an       #
#                      option to do that.                                      #
# 2013/03/25  dboth    Move disabling of PackageKit to much earlier in main    #
#                      code path.                                              #
# 2013/03/26  dboth    Added David's root crontab to /var/spool/cron. Removed  #
#                      desktop installation from the -A option.                #
# 2013/03/31  dboth    Added code that adds code to /etc/bashrc to set an      #
#                      alias for vim to set the colorscheme to "desert".       #
# 2013/04/01  dboth    Removed some fonts that were not particularly useful.   #
# 2013/06/01  dboth    Revised code for the vim alias in /etc/bashrc to have   #
#                      the correct quotes so that it works correctly.          #
# 2013/06/08  dboth    Fixed spelling in help text.                            #
# 2013/06/23  dboth    Removed installation of ATRPM repository.               #
# 2013/07/05  dboth    Removed some non-english fonts.                         #
# 2013/07/07  dboth    Check for each GPG key link separately. Problem may be  #
#                      fixed in Fedora 19.                                     #
#                      Remove Evolution from my own hosts.                     #
# 2013/07/09  dboth    Fixed syntax bug in Development section.                #
#                      Added missing "server" section back in.                 #
# 2013/07/19  dboth    Combined duplicate variable names $Release and          #
#                      $RELEASE to $RELEASE.                            #
#                      - Added code to install iptables-services RPM for       #
#                        Fedora 19 and later.                                  #
#                      - Increased $MinFedoraRelesae to 17.                    #
#                      - Install MariaDB instead of MySQL for Fedora 19 and    # 
#                        over.                                                 #
# 2013/07/23  dboth    Revised RPM detection logic for some sections of code   #
#                      to use PMisInstalled procedure.                         #
#                      - Added DHCP installation to servers.                   #
#                      - Added code to display version of postinstall.sh.      #
# 2013/08/02  dboth    Significant logic changes. Mostly to determine          #
#                      whether ANY desktops are installed in case of           #
#                      no-desktop servers. This can prevent installing KDM and #
#                      all the related KDE programs.                           #
# 2013/08/17  dboth    Add code to remove PackageKit-yum-plugin and apper to   #
#                      ensure that PackageKit does not run. PackageKit         #
#                      conflicts with manual or cron-driven updates.           #
#                      Completely revised CentOS code to be more contained in  #
#                      one logical location and to only install server related #
#                      packages as well as administrative tools.               #
# 2013/10/22  dboth    Add code to remove PackageKit itself when the -q        #
#                      option is specified. Place this code after Desktop      #
#                      installation to ensure that it is removed after being   #
#                      installed by the desktops.                              #
# 2013/10/25  dboth    - Add option to revert to IPTables instead of firewalld #
#                      - Removed Lilypond fonts which are no longer available. #
# 2013/10/26  dboth    - Removed installation of stellarium-doc. Obsoleted by  #
#                        the stellarium RPM.                                   #
#                      - Added logic to NOT remove ModemManager in CentOS due  #
#                        to a number of bad dependencies.                      #
# 2013/10/27  dboth    - Added Thunderbird to "Applications" install. Must     #
#                        have been previously deleted accidentally.            #
# 2013/11/27  dboth    - Added code to SSH restart to check for CentOS to use  #
#                        service command instead of systemctl.                 #
# 2013/11/28  dboth    - Added code to stop and disable unneeded services.     #
#                      - Relocated PackageKit removal to very early in the     #
#                        process to ensure there is no conflict if user is     #
#                        logged in via the GUI.                                #
#                      - Modified code to allow install of GNOME, KDE and      #
#                        LibreOffice for CentOS.                               #
# 2014/01/04  dboth    - Added code to stop and disable firstboot on CentOS.   #
#                      - Removed restrictions on installing applications for   #
#                        CentOS.                                               #
# 2014/01/16  dboth    - Increased Fedora minimum release to 18.               #
# 2014/01/30  dboth    Added libpwquality to common admin tools for            #
#                      installation. The pwmake yutility generates good        #
#                      passwords.                                              #
# 2014/02/01  dboth    Added x86info to common admin tools.                    #
# 2014/02/11  dboth    Deleted all code to remove ModemManager as it is now    #
#                      required for the KDE Network Management plasmoid.       #
# 2014/02/20  dboth    Altered logic to always install sendmail and            #
#                      sendmail-cf for all hosts. Even if they are not email   #
#                      servers, they may need to forward email to the          #
#                      "smart host" for the domain. This can prevent external  #
#                      Name Services problems.                                 #
# 2014/02/22  dboth    Do not turn off ip6tables.                              #
# 2014/03/18  dboth    Repair some logic bugs.                                 #
# 2014/03/19  dboth    Only install root crontab if none already present.      #
# 2014/03/20  dboth    - Add dictd (CLI Dictionary client) to CommonAdminTools #
#                        procedure, but it is only available in Fedora.        #
#                      - Moved modification of /etc/aliases to after install   #
#                        of sendmail.                                          #
#                      - Added a test for Xorg as a check for CLI only.        #
#                      - Only install and activate KDM if there is a GUI       #
#                        installed, i.e., Xorg is installed. See above.        #
# 2014/03/21  dboth    - The RPM installs the replacement IPTables rules in    #
#                        /root.                                                #
#                      - Only install the new defailt IPTables rules if none   #
#                        already exist in /etc/sysconfig.                      #
# 2014/03/22  dboth    - Add a check in case options indicate the user wants   #
#                        install anything that will install a GUI desktop on a #
#                        host that currently has no GUI desktop, i.e., a       #
#                        minimal system or infrastructure server.              #
#                      - Add a -y option to skip asking YNQ for user response. #
# 2014/03/25  dboth    Made some minor logic flow alterations.                 #
# 2014/03/26  dboth    Turned verbose on for the sanity check items and then   #
#                      converted them all to use the PrintMsg procedure.       #
# 2014/04/07  dboth    Improved logic to prevent attempting to install KDM on  #
#                      a system with no desktops installed.                    #
# 2014/04/12  dboth    Move installation of lshw and other admin tools prior   #
#                      to creating the first MOTD as lshw is required.         #
# 2014/04/16  dboth    Added Rootkit Hunter, rkhunter, to list of admin tools  #
#                      installed in non-classroom environments. After all      #
#                      other installs and configuration changes, the command   #
#                      rkhunter --propupd is run to initialize the rkhunter    #
#                      database.                                               #
# 2014/04/20  dboth    Moved rkhunter installation to the very end to prevent  #
#                      issues with false positives in system files due to      #
#                      updates.                                                #
# 2014/05/14  dboth    Install fail2ban and jwhois in admin tools.             #
# 2014/07/24  dboth    Modifications to support Centos 7.                      #
# 2014/07/28  dboth    simplify code to determine CentOS / Fedora and which    #
#                      version to make more generic.                           #
# 2014/07/30  dboth    Use $HOSTTYPE environment variable to get hardware      #
#                      architecture.                                           #
# 2014/09/03  dboth    - Add EPEL for CentOS 7. RPMFusion still not available. #
#                      - Install deltarpm for all environments.                #
#                      - Minor logic adjustments.                              #
# 2014/10/18  dboth    Add option to remove PackageKit and Apper rather than   #
#                      just doing it automatically. Disable during running of  #
#                      this program if not removed.                            #
# 2014/11/04  dboth    Use FTP in wget statements so that file globbing can be #
#                      used when downloading the EPEL and RPMFusion RPMs. This #
#                      means not having to change the release numbers every    #
#                      time and update occurs.                                 #
# 2014/11/06  dboth    Add section to CommonAdminTools procedure for install   #
#                      of GUI based admin tools.                               #
# 2014/11/26  dboth    Removed "here" script that installs the file            #
#                      /etc/cron.daily/tmpwatch                                #
# 2015/03/05  dboth    Corrected download URL for CentOS EPEL repository RPM.  #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
#                                                                              #
################################################################################
################################################################################
#                                                                              #
#  Copyright (C) 2007, 2014  David Both                                        #
#  Millennium Technology Consulting LLC                                        #
#  http://www.millennium-technology.com                                        #
#                                                                              #
#  This program is free software; you can redistribute it and/or modify        #
#  it under the terms of the GNU General Public License as published by        #
#  the Free Software Foundation; either version 2 of the License, or           #
#  (at your option) any later version.                                         #
#                                                                              #
#  This program is distributed in the hope that it will be useful,             #
#  but WITHOUT ANY WARRANTY; without even the implied warranty of              #
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
#  GNU General Public License for more details.                                #
#                                                                              #
#  You should have received a copy of the GNU General Public License           #
#  along with this program; if not, write to the Free Software                 #
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   #
#                                                                              #
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
# Functions MUST go here                                                       #
################################################################################
################################################################################

################################################################################
# Help                                                                         #
################################################################################
Help()
{
   # Display Help
   echo "################################################################################"
   echo "postinstall.sh: Installs useful administrative tools and programs. "
   echo
   echo "This script is installed by the postinstall RPM package. It is "
   echo "intended for use with Fedora 19 and above. It has been tested up"
   echo "through Fedora 20 as of July 2014. This program also supports CentOS 6 and 7. 
   echo "It only installs administrative tools and server applications for 
   echo "CentOS -- NOT desktop programs."
   echo
   echo "This program installs the RPMFusion free and non-free repositories if"
   echo "they are not already. It also installs all current updates."
   echo
   echo "Syntax: ./postinstall.sh -[h]|[V][aCDdfGgiKLlmrStTVvX]|[A]"
   echo "################################################################################"
   echo "options:"
   echo "A     All: Install Applications, LibreOffice, Multimedia, and fonts."
   echo "           Does not install Development packages or servers."
   echo "--------------------------------------------------------------------------------------"
   echo "a     Install various GUI desktop applications including graphics, Adobe"
   echo "          repository and Flash, and krusader file manager."
   echo "d     Install development packages such as the kernel devlopment."
   echo "        -- This will be needed if you are going to install VirtualBox."
   echo "f     Install more desktop fonts from repository."
   echo "i     Revert to iptables instead of using firewalld."
   echo "l     Install LibreOffice."
   echo "m     Install various multimedia applications for DVD playback and streaming video."
   echo "p     Removes PackageKit and all its plugins as well as apper."
   echo "q     Install some basic non-graphical things unique to the developer's environments."
   echo "        -- NOT for systems outside of the developer's domains."
   echo "r     Reboot after completion."
   echo "s     Install server software packages."
   echo "T     If you are in a training environment, this installs a few tools but"
   echo "          leaves most for the students to install. It also creates a"
   echo "          student ID, student, with a password of lockout."
   echo "          This is for the Millennium Technology Consulting LLC "
   echo "          Theory and practice of Linux System Administration course."
   echo "t     If you are in a training environment, this installs a complete"
   echo "          set of tools for beginning students. It also creates a"
   echo "          student ID, student, with a password of lockout."
   echo "          This is for the Millennium Technology Consulting LLC "
   echo "          Introduction to Linux course."
   echo "u     Add a student user. This is for an environment that might not be"
   echo "          for training but might be used for testing."
   echo "v     Verbose mode."
   echo "V     Print the version of this software and exit."
   echo "--------------------------------------------------------------------------------------"
   echo "###### Options to install Desktops -- Only KDE and Gnome are available for CentOS ######"
   echo "D     Install all desktops listed below."
   echo "C     Install Cinnamon Desktop. Only available on Fedora 18 and over."
   echo "G     Install Gnome Desktop."
   echo "K     Install KDE desktop."
   echo "L     Install LXDE desktop."
   echo "M     Install MATE desktop."
   echo "S     Install Sugar desktop for kids."
   echo "X     Install Xfce desktop."
   echo "--------------------------------------------------------------------------------------"
   echo "###### Miscellaneous Options  ######"
   echo "--------------------------------------------------------------------------------------"
   echo "y     Automatically answer Yes to all questions that require input of YNQ."
   echo "h     Print this Help."
   echo "g     Print the GPL License header."
   echo "################################################################################"
   echo "This BASH program is distributed under the GPL V2." 
   echo
   echo "It is suggested you redirect all output to a log file"
   echo "to retain a record of what tasks were perfomed. Example below:"
   echo "./postinstall.sh -[Your chosen options] > /root/postinstall.log 2>&1"
}

################################################################################
# Print the GPL license header                                                 #
################################################################################
gpl()
{
   echo
   echo "################################################################################"
   echo "#  Copyright (C) 2007, 2014  David Both                                        #"
   echo "#  Millennium Technology Consulting LLC                                        #"
   echo "#  http://www.millennium-technology.com                                        #"
   echo "#                                                                              #"
   echo "#  This program is free software; you can redistribute it and/or modify        #"
   echo "#  it under the terms of the GNU General Public License as published by        #"
   echo "#  the Free Software Foundation; either version 2 of the License, or           #"
   echo "#  (at your option) any later version.                                         #"
   echo "#                                                                              #"
   echo "#  This program is distributed in the hope that it will be useful,             #"
   echo "#  but WITHOUT ANY WARRANTY; without even the implied warranty of              #"
   echo "#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #"
   echo "#  GNU General Public License for more details.                                #"
   echo "#                                                                              #"
   echo "#  You should have received a copy of the GNU General Public License           #"
   echo "#  along with this program; if not, write to the Free Software                 #"
   echo "#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   #"
   echo "################################################################################"
   echo
}

################################################################################
# Quit nicely with messages as appropriate                                     #
################################################################################
Quit()
{
   if [ $error != 0 ]
   then 
      echo "Program terminated with error ID $error"
      rc=$error
   else
      if [ $verbose = 1 ]
      then
         echo "Program terminated normally"
         rc=0
      fi
   fi

   exit $rc
}

################################################################################
# Gets simple (Y)es (N)o (Q)uit response from user. Loops until                #
# one of those responses is detected.                                          #
################################################################################
ynq()
{
   # loop until we get a good answer and break out
   while [ $OK = 0 ] 
   do
      # Print the message
      echo -n "$message (ynq) "
      # Now get some input
      read input
      # Test the input
      if [ -z $input ]
      then
         # Invalid input - null
         echo "INPUT ERROR: Must be y or n or q in lowercase. Please try again."
      elif [ $input = "yes" ] || [ $input = "y" ]
      then
         response="y"
         OK=1
      elif [ $input = "no" ] || [ $input = "n" ]
      then
         response="n"
         OK=1
      elif [ $input = "Help" ] || [ $input = "h" ]
      then
         Help
      elif [ $input = "q" ] || [ $input = "quit" ]
      then
         Quit
      else
         # Invalid input
         echo "INPUT ERROR: Must be y or n or q in lowercase. Please try again."
      fi
   done
}

################################################################################
# Determines whether a given RPM package is installed. Returns 0 if true and 1 #
# if false. Does not do file globbing but is fast.                             #
################################################################################
RPMisInstalled()
{
   # See if the RPM exists
   if  rpm -q $RPMname > /dev/null
   then
      Msg="RPM $RPMname is installed" 
      rc=0
   else
      Msg="RPM $RPMname is NOT installed"
      rc=1
   fi
   PrintMsg
   return $rc
} # end RPMisInstalled

################################################################################
# Determines whether a given RPM group is installed. Returns 0 if true and 1   #
# if false.                                                                    #
################################################################################
GroupisInstalled()
{
   # See if the Group exists
   Result=`yum grouplist installed "$GroupName" | grep "$GroupName"` > /dev/null
   Length=${#Result}
   if [ $Length -gt 0 ]
   then
      Msg="RPM $GroupName is installed" 
      rc=0
   else
      Msg="RPM $GroupName is NOT installed"
      rc=1
   fi
   PrintMsg
   return $rc
} # end GroupisInstalled

################################################################################
# Install the Fedora  RPM Fusion repositories                                  #
################################################################################
installFedoraRPMFusionRepo()
{
   cd
   # Ensure that the RPMFusion repositories are installed
   RPMname="rpmfusion-free-release"
   if ! RPMisInstalled
   then
      Msg="Installing the RPMFusion free repository for Fedora"
      PrintMsg
      wget -c http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-stable.noarch.rpm
      rpm -ivh rpmfusion-free-release-stable.noarch.rpm
   fi
   RPMname="rpmfusion-nonfree-release"
   if ! RPMisInstalled
   then
      Msg="Installing the RPMFusion nonfree repository for Fedora"
      PrintMsg
      wget -c http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-stable.noarch.rpm
      rpm -ivh rpmfusion-nonfree-release-stable.noarch.rpm
   fi

   # Now set the correct symlinks for RMPFusion for as they are not always
   # installed by the RPMFusion installation RPMs. This started with Fedora 18.
   # First check to see if they are there, just in case this gets fixed
   # Note 07/07/2013: This may be fixed in Fedora 19.
   cd /etc/pki/rpm-gpg
   if [ ! -e RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE ]
   then
      Msg="Installing RPMFusion GPG Key link  RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE"
      PrintMsg
      # Add the link
      ln -s RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-primary  RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE
   fi 
   if [ ! -e RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-i386 ]
   then
      Msg="Installing RPMFusion GPG Key link  RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-i386"
      PrintMsg
      # Add the link
      ln -s RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-primary  RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-i386
   fi
   if [ ! -e RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-x86_64 ]
   then
      Msg="Installing RPMFusion GPG Key link  RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-x86_64"
      PrintMsg
      # Add the link
      ln -s RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-primary  RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-x86_64
   fi
   if [ ! -e RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE ]
   then
      Msg="Installing RPMFusion GPG Key link  RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE"
      PrintMsg
      # Add the link
      ln -s RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE-primary  RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE
   fi
   if [ ! -e RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-i386 ]
   then
      Msg="Installing RPMFusion GPG Key link  RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE-i386"
      PrintMsg
      # Add the link
      ln -s RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE-primary  RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE-i386
   fi
   if [ ! -e RPM-GPG-KEY-rpmfusion-free-fedora-$RELEASE-x86_64 ]
   then
      Msg="Installing RPMFusion GPG Key link  RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE-x86_64"
      PrintMsg
      # Add the link
      ln -s RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE-primary  RPM-GPG-KEY-rpmfusion-nonfree-fedora-$RELEASE-x86_64
   fi
   cd
}
# end installFedoraRPMFusionRepo

################################################################################
# Install EPEL and the CentOS RPM Fusion repositories                          #
################################################################################
################################################################################
################################################################################
################################################################################
################################################################################
# Need to configure this to deal with CentOS 7 also
################################################################################
################################################################################
################################################################################
installCentOSRPMFusionRepo()
{
   # Ensure the PWD is /root
   cd
   # Which version of CentOS? Unfortunately there are enough differences in the URLs that 
   # it is easier to do it this way than with the $RELEASE number as part of the URL.
   if [ $RELEASE -eq 6 ]
   then
      # Install for CentOS 6
      # First enable EPEL http://fedoraproject.org/wiki/EPEL/FAQ#howtouse
      # According to a couple sources it is required BEFORE adding RPMFusion repos
      # Note that this is specifically for CentOS 6.x
      RPMname="epel-release"
      if ! RPMisInstalled
      then
         Msg="Installing EPEL (Extra Packages for Enterprise Linux)"
         wget http://mirrors.kernel.org/fedora-epel/6/x86_64/epel-release-6-8.noarch.rpm
         yum install -y epel-release-6-*.noarch.rpm
      fi
      # Ensure that the RPMFusion repositories are installed
      RPMname="rpmfusion-free-release"
      if ! RPMisInstalled
      then
         Msg="Installing the RPMFusion free repository for CentOS"
         PrintMsg
         wget -c http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm
         yum -y install --nogpgcheck rpmfusion-free-release-6-1.noarch.rpm
      fi
      RPMname="rpmfusion-nonfree-release"
      if ! RPMisInstalled
      then
         Msg="Installing the RPMFusion nonfree repository for CentOS"
         PrintMsg
         wget -c http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm
         yum -y install --nogpgcheck rpmfusion-nonfree-release-6-*.noarch.rpm
      fi
   elif [ $RELEASE -eq 7 ]
   then
      # Install for CentOS 7
      # First enable EPEL http://fedoraproject.org/wiki/EPEL/FAQ#howtouse
      # According to a couple sources it is required BEFORE adding RPMFusion repos
      # Note that this is specifically for CentOS 6.x
      RPMname="epel-release"
      if ! RPMisInstalled
      then
         Msg="Installing EPEL (Extra Packages for Enterprise Linux)"
         wget -c http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
         yum install -y epel-release-7-*.noarch.rpm
      fi
      ################################################################################
      ################################################################################
      ################################################################################
      # Note: Fedora RPMFusion repo is not available for CentOS7 as of 09/01/2014    #
      ################################################################################
      ################################################################################
      ################################################################################
      
   else
      # Not a known CentOS release
      Msg="CentOS $RELEASE is not supported by this program."
      PrintMsg
   fi
   # Remove the rpms
   # rm -f rpmfusion-*rpm
}
# end installCentosRPMFusionRepo

################################################################################
# Install the Adobe YUM repository if it is not already installed, and Flash.  #
################################################################################
installAdobeRepo()
{
   cd
   # Which Architecture?
   if [ $Arch = 32 ]
   then
      # Ensure that the Adobe repository is installed
      RPMname="adobe-release-i386"
      if ! RPMisInstalled
      then
         Msg="Installing the Adobe 32 bit Release repository"
         PrintMsg
         wget -c http://linuxdownload.adobe.com/linux/i386/adobe-release-i386-1.0-1.noarch.rpm
         yum -y install --nogpgcheck adobe-release-i386-1.0-1.noarch.rpm
         # Remove the rpm 
         rm -f adobe-release-i386-1.0-1.noarch.rpm
      fi
   elif [ $Arch = 64 ]
   then
      # Ensure that the Adobe repository is installed
      RPMname="adobe-release-x86_64"
      if ! RPMisInstalled
      then
         Msg="Installing the Adobe Release repository"
         PrintMsg
         wget -c http://linuxdownload.adobe.com/linux/x86_64/adobe-release-x86_64-1.0-1.noarch.rpm
         yum -y install --nogpgcheck adobe-release-x86_64-1.0-1.noarch.rpm
         # Remove the rpm 
         rm -f adobe-release-i386-1.0-1.noarch.rpm
      fi
   else
      # Invalid architecture
      Msg="Invalid archiecture $Arch attempting to install Adobe Flash"
      PrintMsg
   fi
}
# end installAdobeRepo


################################################################################
# Display verbose messages in a common format                                  #
################################################################################
PrintMsg()
{
   if  [ $verbose = 1 ] && [ -n "$Msg" ]
   then
      echo "########## $Msg ##########"
      # Set the message to null
      Msg=""
   fi
}

################################################################################
# Install the RPMs in a list                                                   #
################################################################################
InstallRPMList()
{
   Msg="Installing packages: $RPMlist"
   PrintMsg
   yum -y install $RPMlist
   # Null out the list of RPMs
   RPMlist=""
} # end InstallRPMList

OldInstallRPMList()
{
   for RPMname in $RPMlist
   do
      if ! rpm -q $RPMname > /dev/null
      then 
         # The RPM is not currently installed and will be installed
         Msg="Installing $RPMname"
         PrintMsg
         yum -y install $RPMname
      else
         # The RPM is already installed
         Msg="$RPMname is already installed"
         PrintMsg
      fi
   done
   # Null out the list of RPMs
   RPMlist=""
} # end OldInstallRPMList

################################################################################
# Get Distribution architecture 64/32 bit                                      #
################################################################################
GetDistroArch()
{
   #---------------------------------------------------------------------------
   # Get the host physical architecture
   HostArch=`echo $HOSTTYPE | tr [:lower:] [:upper:]`
   Msg="The host physical architecture is $HostArch"
   PrintMsg
   #---------------------------------------------------------------------------
   # Get some information from the *-release file. We care about this to give
   # us Fedora or CentOS version number and because some group names change between 
   # release levels.
   #---------------------------------------------------------------------------
   # First get the distro info out of the file in a way that produces consistent results
   # for Fedora and CentOS 6 and 7. The CentOS 7 file adds the word "Linux" and screws
   # things up.
   Distro=`cat /etc/*elease* 2>/dev/null | grep release | uniq | sed -e "s/[lL]inux //g"`
   FULL_RELEASE=`echo $Distro | awk '{print $3}'`
   
   if echo $Distro | grep Fedora > /dev/null
   then 
      # This is Fedora
      NAME="Fedora"
      # The Release version is the same as the full release number, i.e., no minor versions for Fedora
      RELEASE=$FULL_RELEASE
      #---------------------------------------------------------------------------
      # Verify Fedora release $MinFedoraRelease= or above. This is due to the lack 
      # of Fedora and Fusion repositories prior to that release.
      #---------------------------------------------------------------------------
      if [ $RELEASE -lt $MinFedoraRelease ]
      then 
         Msg="Release $RELEASE of Fedora is not supported. Only releases $MinFedoraRelease and above are supported."
         PrintMsg
         error=2
         Quit $error   
      fi
   elif echo $Distro | grep CentOS > /dev/null
   then
      # This is CentOS
      NAME="CentOS"
      # Get the CentOS major version number
      RELEASE=`echo $FULL_RELEASE | awk -F. '{print $1}'`
   
      #---------------------------------------------------------------------------
      # Verify CentOS release $MinCentOSRelease= or above. This is due to the lack
      # of testing for this program prior to that release.
      #---------------------------------------------------------------------------
      if [ $RELEASE -lt $MinCentOSRelease ]
      then
         Msg="Release $RELEASE of CentOS is not supported. Only releases $MinCentOSRelease and above are supported."
         PrintMsg
         error=4
         Quit $error
      fi
   else
      Msg="Unsupported OS: $NAME"
      PrintMsg
      error=2
      Quit $error
   fi
   
   Msg="Distribution = $Distro" 
   PrintMsg
   Msg="Name = $NAME  Release = $RELEASE Full Release = $FULL_RELEASE"
   PrintMsg
   # Now lets find whether Distro is 32 or 64 bit
   if uname -r | grep x86_64 > /dev/null
   then 
      # Just the bits
      Arch="64"
   else 
      # Just the bits
      Arch="32"
   fi
   if [ $verbose = 1 ]
   then 
      Msg="This is a $Arch bit version of the Linux Kernel."
      PrintMsg
   fi
}

################################################################################
# Install KDM and activate it.                                                 #
################################################################################
activateKDM()
{
   # Only do this if this computer has a GUI desktop environment
   if [ $CLIonly = 0 ]
   then
      RPMlist="kdm"
      InstallRPMList
      # make KDM the active display manager
      Msg="Make KDM the active display manager"
      PrintMsg
      cd /etc/systemd/system/
      if ! ls -l | grep kdm.service
      then
         rm -f display-manager.service
         ln -s /usr/lib/systemd/system/kdm.service display-manager.service
      fi
   fi
} # End activateKDM

################################################################################
# Add a student user.                                                          #
################################################################################
AddStudent()
{
   # Add user "student" with password "lockout"
   User="student"
   if ! grep "$User:x:" /etc/passwd > /dev/null
   then
      Msg="Adding the user: $User"
      PrintMsg
      # Add the user
      useradd -c "Student User" $User
      # Set the password
      echo "$User:lockout" | chpasswd
   else
      Msg="User $User not added. Already present."
      PrintMsg
   fi
}

################################################################################
# Common tasks for Pretty much most environments.                              #
################################################################################
CommonAdminTools()
{
   ################################################################################
   # install some CLI administrative tools for both Fedora and CentOS 6 and 7.    #
   ################################################################################
   Msg="Installing some useful administration tools for the common environments."
   RPMlist="mc screen vim-common vim-enhanced vim-filesystem vim-minimal libpwquality x86info fail2ban deltarpm"
   PrintMsg
   InstallRPMList

   ################################################################################
   # Install some CLI packages that are distro and release sensitive.             #
   ################################################################################
   if [ $NAME = "Fedora" ]
   then 
      # Install some packages for Fedora only.
      Msg="Installing some useful administration tools for Fedora only"
      RPMlist="dictd whois"
      PrintMsg
      InstallRPMList
   elif [ $NAME = "CentOS" ] && [ $RELEASE -lt 7 ]
   then 
      # Install packages for CentOS 6
      Msg="Installing some useful administration tools for CentOS 6.x only"
      RPMlist="jwhois"
      PrintMsg
      InstallRPMList
   elif [ $NAME = "CentOS" ] && [ $RELEASE -ge 7 ]
   then 
      # Install packages for CentOS 7
      Msg="Installing some useful administration tools for CentOS 7.x only"
      RPMlist="whois"
      PrintMsg
      InstallRPMList
   else
      Msg="Not a valid Distribution and Release combination."
      PrintMsg
   fi

   ################################################################################
   # Install some admin tools for GUI environments                                #
   ################################################################################
   if [ $CLIonly -eq 1 ]
   then
      Msg="Installing some GUI administration tools"
      RPMlist="yumex xfe"
      PrintMsg
      InstallRPMList
   fi # End CLI admin tools only

} # end of CommonAdminTools  

################################################################################
# Revert to IPTables instead of using firewalld                                #
################################################################################
RevertIPTables()
{
   Msg="Reverting from firewalld to IPTables."
   PrintMsg
   
   ################################################################################
   # Only use a new default set of IPTables rules if a file does not already      #
   # exist.                                                                       #
   ################################################################################
   if [ ! -e /etc/sysconfig/iptables ]
   then
      # Copy new IPTables file 
      cp /root/iptables /etc/sysconfig/iptables
      cd
   fi
   # Stop NetworkManager for security while the firewall is down
   systemctl stop NetworkManager.service
   systemctl stop firewalld.service
   systemctl disable firewalld.service
   systemctl start iptables.service
   systemctl enable iptables.service
   # Restart the network
   systemctl start NetworkManager.service
}

################################################################################
# Perform tasks only to be done on one of my own systems. This makes it easier #
# to use this on systems that are not my own. These tasks are NOT performed on #
# classroom systems. None of these tasks install graphical RPMs so can be used #
# on non-GUI systems.                                                          #
#                                                                              #
# Add my email address to /etc/aliases                                         #
# Add user "dboth" with simple temporary password                              #
# Install personal default MC Midnight Commander configuration files           #
# Install the root crontab for david's computers                               #
#                                                                              #
################################################################################
DoDavidsStuff()
{
   Msg="Performing tasks specifically for David's own systems."
   PrintMsg

   ################################################################################
   # Add user "dboth" with password only if it does not already exist.            #
   ################################################################################
   User="dboth"
   if ! grep "$User:x:" /etc/passwd > /dev/null
   then
      Msg="Adding the user: $User"
      PrintMsg
      # Add the user
      useradd -c "David Both" $User
      # Set a temporary pre-encrypted password
      echo 'dboth:$6$llrTh4eM$wfOPpVRNXEpwZEaxFPZLzp19Qd7pNyHf8QiAbMWMttZrLVD5f3rE1rGGC0mCln7O8Zf5eZsPgu5bPvrpJD1dd1' | chpasswd -e
   else
      Msg="User already exists: $User"
      PrintMsg
   fi

   ################################################################################
   # Install personal default MC Midnight Commander configuration files in the    #
   # correct location. It is different for more recent versions.                  #
   ################################################################################
   Msg="Setting color configuration for Midnight Commander."
   PrintMsg
   # Check the man page to see which location is being used for the config files
   if man mc | grep "~/.mc/" > /dev/null
   then
      # This is the old location for the mc config files
      mkdir -p /root/.mc
      cp /root/mcconfigfiles/* /root/.mc
   elif man mc | grep "~/.config/mc/ini" > /dev/null
      then
      # This is the new desktop location for the mc config files
      mkdir -p /root/.config/mc
      cp /root/mcconfigfiles/* /root/.config/mc
   else
      # Did not find either mc config file location
      Msg="ERROR: configuration files for mc not found."
      PrintMsg
   fi


   # Intentionally leave new config files in /root/mcconfigfiles
} # End DoDavidsStuff

################################################################################
# If Anaconda was deleted when PackageKit was removed -- and it probably was --#
# resintall it. But only reinstall if this is Fedora.                          #
#    This procedure is not currently used.                                     # 
################################################################################
ReinstallAnaconda()
{
RPMname="anaconda"
if ! RPMisInstalled && [ $NAME = "Fedora" ]
then
   Msg="Reinstalling $RPMname"
   PrintMsg
   yum -y install $RPMname
fi
} # End ReinstallAnaconda


################################################################################
################################################################################
# Main program                                                                 #
################################################################################
################################################################################
# Set initial variables
applications=0
Arch=""
HostArch=""
badoption=0
CLIonly=0
DavidsStuff=0
development=0
server=0
error=0
fonts=0
GroupName=""
input=""
IPTablesRevert=0
LibreOffice=0
MinFedoraRelease="17"
MinCentOSRelease="6"
Msg=""
multimedia=0
NAME=""
OK=0
rc=0
reboot=0
response="n"
RELEASE=""
removePackageKit=0
FULL_RELEASE=""
RPMlist=""
RPMname=""
student=0
TrainingAdvanced=0
TrainingIntro=0
verbose=0
version="7.0.3"
##### Desktop variables #####
cinnamon=0
gnome=0
kde=0
lxde=0
mate=0
sugar=0
xfce=0
Yes=0

################################################################################
# Do some sanity checking                                                      #
################################################################################
# Set verbose on for this sanity checking
verbose=1
#---------------------------------------------------------------------------
# Check for root
if [ `id -u` != 0 ]
then
   Msg="You must be root to run this program"
   PrintMsg
   error=3
   Quit $error
fi
#---------------------------------------------------------------------------
# Check for Linux
if [[ "$(uname -s)" != "Linux" ]]
then
   Msg="This script is for Linux only -- OS detected: $(uname -s)."
   PrintMsg
   error=1
   Quit $error
fi

#---------------------------------------------------------------------------
# Now turn verbose back off so that the -v option will take precedence
# after the input options are processed below.
verbose=0

################################################################################
# Process the input options                                                    #
################################################################################
# Get the options
while getopts ":AaCcDdfGghiKlLmMopqrsSTtuVvXy" option; do
   case $option in
      A) # Set All mode to install everything except desktops, servers and classroom stuff
         applications=1
         LibreOffice=1
         multimedia=1
         fonts=1
         server=0
         development=0;;
      a) # Set Applications mode
         applications=1;;
      C) # Install Cinnamon Desktop
         cinnamon=1;;
      d) # Set development mode
         development=1;;
      D) # Install all desktops
         cinnamon=1
         gnome=1
         kde=1
         lxde=1
         mate=1
         sugar=1
         xfce=1;;
      f) # Set fonts mode
         fonts=1;;
      G) # Install Gnome Desktop
         gnome=1;;
      g) # Print GPL header
         gpl
         Quit;;
      i) # Revert to IPTables
         IPTablesRevert=1;;
      K) # Install KDE Desktop
         kde=1;;
      l) # Set LibreOffice mode
         LibreOffice=1;;
      L) # Install LXDE Desktop
         lxde=1;;
      M) # Install MATE Desktop
         mate=1;;
      m) # Set multimedia mode
         multimedia=1;;
      p) # Remove PackageKit
         removePackageKit=1;;
      q) # Set David's stuff mode
         DavidsStuff=1;;
      r) # Set reboot mode
         reboot=1;;
      s) # Install servers
         server=1;;
      S) # Install Sugar Desktop
         sugar=1;;
      T) # Training mode for Advanced classes
         TrainingAdvanced=1;;
      t) # Training mode for Intro classes
         TrainingIntro=1;;
      u) # Add student user
         student=1;;
      v) # Set verbose mode
         verbose=1;;
      V) # Print the software version and exit
         echo "Version $version"
         Quit;;
      X) # Install Xfce Desktop
         xfce=1;;
      y) # Yes option ignores request for user input
         Yes=1;;
      h) # display Help
         Help
         Quit;;
     \?) # incorrect option
         badoption=1;;
   esac
done

################################################################################
# Display the CLI command and some other data for posterity                    #
################################################################################
Msg="Command options = $*"
PrintMsg

# Get the distribution information and Architecture, 64/32 bit
GetDistroArch


################################################################################
# Does this system have Xorg installed? If not it is currently CLI only.       #
################################################################################
RPMname="xorg-x11-server-utils"
if ! RPMisInstalled
then
   CLIonly=1
   Msg="This is a Command Line only system. No GUI desktop installed."
else
   Msg="This is a GUI System with at least one desktop installed."
fi
PrintMsg

################################################################################
# Do some sanity checking                                                      #
################################################################################
# Check for an invalid option
if [ $badoption = 1 ]
   then
   echo "ERROR: Invalid option"
   Help
   verbose=1
   error="10T"
   Quit 1
fi

################################################################################
# Check for option conflicts with non-GUI systems.                             #
################################################################################
if [ $CLIonly = 1 ] && ( [ $cinnamon = 1 ] || [ $lxde = 1 ] || [ $mate = 1 ] || [ $sugar = 1 ] || [ $xfce = 1 ] || [ $kde = 1 ] || [ $gnome = 1 ] || [ $applications = 1 ] || [ $multimedia = 1 ] || [ $LibreOffice = 1 ] ) 
then 
   echo "#############################################################################################"
   echo "###  WARNING!!!   WARNING!!!  WARNING!!!  WARNING!!!  WARNING!!!  WARNING!!!  WARNING!!!  ###"
   echo "###         The selected options are incompatible with a non-GUI host system.             ###"
   echo "#############################################################################################"
   echo "### If you continue, you will install at least one GUI desktop on a host that currently   ###"
   echo "### does not have a GUI.                                                                  ###"
   echo "#############################################################################################"
   # Ask if we want to continue, which would install at least one GUI desktop
   message="WARNING!!! Do you wish to continue and add a GUI desktop and all the many associated packages?"

   # Is the "Yes" option selected?
   if [ $Yes = 0 ]
   then
      # If the -y "Yes" option is not selected, give the user an option to proceed or not
      ynq

      if [ $response = "n" ]
      then
         Msg="The selected options are incompatible with a non-GUI host system."
         PrintMsg
         error=5
         Quit $error
      fi # End of ynq response for "no"
   fi # End of the Yes option was NOT selected

   # This is what we do whether the -y option was selected initially as a program option or as a 
   # response to the "ynq" procedure.
   Msg="User Intervention: Continuing installation of options that will install at least one GUI desktop on a host that currently does not have one."
   PrintMsg
   # We will be installing a CLI
   CLIonly=0


   ################################################################################
   # Now, since we are going to install a GUI, we need to install a few basics.   #
   ################################################################################
   Msg="Installing some of the basic packages required for any GUI desktop environment."
   PrintMsg
   RPMlist="xorg-x11-server-common xorg-x11-server-Xorg xorg-x11-server-utils xorg-x11-utils xorg-x11-xinit"
   InstallRPMList

fi # End checking non-GUI conflict


#######################
#######################
#######################
#######################

# Check for option conflicts with CentOS. Throw error messages and Exit
if [ $NAME = "CentOS" ]
then
   # check for desktops
   if [ $cinnamon = 1 ] || [ $lxde = 1 ] || [ $mate = 1 ] || [ $sugar = 1 ] || [ $xfce = 1 ]
   then 
      Msg="The selected Desktop(s) are invalid options on CentOS: Cinnamon, LXDE, Mate, Sugar, XFCE."
      PrintMsg
      error=6
      Quit $error
   fi
fi # End of CentOS option conflict checking

# Cinnamon Desktop is only supported on Fedora 18 and greater
if [ $cinnamon = 1 ] && [ $RELEASE -lt 18 ] && [ $NAME = "Fedora" ]
then
   Msg="The Cinnamon Desktop is only supported on Fedora 18 and over."
   PrintMsg
   error=1
   verbose=1
   Quit $error
fi
# Check for T and t options which are mutually exclusive
if [ $TrainingAdvanced = 1 ] && [ $TrainingIntro = 1 ]
then
   Msg="The T and t options are mutually exclusive"
   PrintMsg
   error=1
   verbose=1
   Quit $error
fi

################################################################################
# Print detected OS and version and postinstall version                        #
################################################################################
Msg="OS Name = $NAME, Version = $RELEASE Architechure = $Arch"
PrintMsg
Msg="postinstall version = $version"
PrintMsg

################################################################################
# Do the common things for both Fedora and Centos                              #
################################################################################
################################################################################
# Remove  PackageKit YUM update to prevent conflicts with YUM installations    #
# below and updates performed as cron jobs. Also remove the YUM plugin for     #
# PackageKit and the apper application.                                        #
################################################################################
if [ $removePackageKit -eq 1 ]
then
   RPMname="PackageKit"
   if RPMisInstalled
   then
      Msg="Removing PackageKit and apper."
      PrintMsg
      yum -y remove PackageKit
   else
      Msg="$RPMname is not installed."
      PrintMsg
   fi
fi

################################################################################
# Ensure prerequisites are present                                             #
################################################################################
# Install wget if not present
RPMname="wget"
if ! RPMisInstalled
then
   Msg="Installing wget"
   PrintMsg
   RPMlist="wget"
   InstallRPMList
fi

################################################################################
# Disable and stop unneeded services.                                          #
################################################################################
Msg="Disabling unneeded services - $NAME."
PrintMsg
if [ $NAME = "Fedora" ] || ( [ $NAME = "CentOS" ] && [ $RELEASE -ge 7 ] )
then
   for I in rpcbind bluetooth pcscd 
   do
      Msg="Working on $I"
      PrintMsg
      systemctl stop $I
      systemctl disable $I
   done
elif [ $NAME = "CentOS" ] && [ $RELEASE -lt 7 ]
then
   for I in nfslock rpcbind rpcgssd rpcidmapd postfix bluetooth netfs portreserve
   do
      Msg="Working on $I"
      PrintMsg
      service $I stop
      chkconfig $I off
   done
fi

################################################################################
# Change all references to IPV6 in ifcfg files to "no". Also change IPV4       #
# peer routes to no.                                                           #
################################################################################
# change into network-scripts directory
Msg="Fixing network interface configuration scripts."
PrintMsg
cd /etc/sysconfig/network-scripts
# Identify the ifcfg files on which to operate
for I in `ls ifcfg* | grep -v ifcfg-lo`
do
   # use sed to replace yes with no in several statements
   sed -i -e 's/IPV6INIT="yes"/IPV6INIT="no"/' $I
   sed -i -e 's/IPV6_PEERDNS="yes"/IPV6_PEERDNS="no"/' $I
   sed -i -e 's/IPV6_DEFROUTE="yes"/IPV6_DEFROUTE="no"/' $I
   sed -i -e 's/IPV6_AUTOCONF="yes"/IPV6_AUTOCONF="no"/' $I
   sed -i -e 's/IPV6_PEERROUTES="yes"/IPV6_PEERROUTES="no"/' $I
   # And this one is for IPV4 peer routes
   sed -i -e 's/PEERROUTES="yes"/PEERROUTES="no"/' $I
done
# return to default directory
cd

################################################################################
# Disable Nepomuk in Fedora 19 and higher.                                     #
################################################################################
if [ $NAME = "Fedora" ] && [ $RELEASE -ge 19 ]
then 
   Msg="Disabling Nepomuk."
   PrintMsg
   cd /usr/share/kde-settings/kde-profile/default/share/config/
   sed -i -e "s/Start Nepomuk=true/Start Nepomuk=false/" nepomukserverrc
   sed -i -e "s/autostart=true/autostart=false/" nepomukserverrc
   cd
fi

################################################################################
# Install additional repositories                                              #
################################################################################
# Install repositories based on Centos or Fedora
Msg="Checking RPM Fusion repository for $NAME"
PrintMsg
if [ $NAME = "Fedora" ]
then
   installFedoraRPMFusionRepo
elif [ $NAME = "CentOS" ]
then
   installCentOSRPMFusionRepo
fi

################################################################################
# Installing dependencies                                                      #
################################################################################
Msg="Checking for dependencies."
PrintMsg
# The compat-libstdc++-33 package is required for Realplayer and the 
# Sun Java browser plugin, as well as some other such as glibc.
RPMlist="compat-libstdc++-33"
InstallRPMList

################################################################################
# Make some configuration changes and do all updates.                          #
################################################################################

Msg="Set installonly_limit to 9."
PrintMsg
cd /etc/
sed -i -e "s/installonly_limit=.*/installonly_limit=9/" yum.conf
cd

# Now do the update
Msg="Performing a YUM update of all installed packages."
PrintMsg
yum -y update

################################################################################
# Some basic configuration changes for all environments                        #
################################################################################
# Turn off SELinux
Msg="Disable SELinux."
PrintMsg
cd /etc/selinux/
sed -i -e "s/SELINUX=enforcing/SELINUX=disabled/" config
cd

################################################################################
# Modify /etc/bashrc                                                           #
################################################################################
Msg="Modify /etc/bashrc - add aliases and set vi CLI editing mode"
PrintMsg
# Back up the current bashrc
cp /etc/bashrc /etc/bashrc.orig
# Add the lsn alias to /etc/bashrc if it does not already exist
if ! grep "alias lsn=" /etc/bashrc > /dev/null
then
   echo "################################################################################" >> /etc/bashrc
   echo "# The following global changes to BASH configuration added by postinstall.sh   #" >> /etc/bashrc
   echo "################################################################################" >> /etc/bashrc
   echo "alias lsn='ls --color=no'" >> /etc/bashrc
   echo "alias vim='vim -c \"colorscheme desert\" '" >> /etc/bashrc
   # Set BASH CLI editing mode to vi
   if ! grep "set -o vi" /etc/bashrc > /dev/null
   then
      echo "set -o vi" >> /etc/bashrc
   fi
fi



################################################################################
# Do these things for Fedora with any Desktop but not for a CLI only system.   #
################################################################################
if [ $NAME = "Fedora" ] && [ $CLIonly = 0 ]
then
   # Install a few RPMs
   Msg="Installing a few RPMs for Fedora desktops."
   PrintMsg
   RPMlist="galculator"
   InstallRPMList
   
   # Install and activate KDM
   activateKDM

fi

################################################################################
# Install the common administration tools for all environments                 #
################################################################################
Msg="Installing common administrative tools for all environments and OS's."
PrintMsg
CommonAdminTools

################################################################################
# Perform tasks for Davids systems.                                            #
################################################################################
if [ $DavidsStuff = 1 ]
then
   DoDavidsStuff
fi

################################################################################
# If in a classroom environment, do less so that the student will have to      #
# do it in the lab projects.                                                   #
################################################################################
if [ $TrainingAdvanced = 1 ]
then
   ################################################################################
   # Do this stuff when we are in an advanced training environment.               #
   ################################################################################
   Msg="Performing tasks specifically for Millennium Technology Consulting LLC Advanced Training hosts."
   PrintMsg
   # Add the student user
   AddStudent
# End of advanced training installation
elif [ $TrainingIntro = 1 ]
then
   ################################################################################
   # Do this stuff when we are in an introductory training environment.           #
   ################################################################################
   Msg="Performing tasks specifically for Millennium Technology Consulting LLC Introductory Training hosts."
   PrintMsg
   # install some administrative tools. 
   Msg="Installing some useful administration tools for the Introductory Training environment."
   PrintMsg
   RPMlist="logwatch ntop atop htop iptraf-ng iotop iftop sysstat lshw hddtemp lm_sensors"
   InstallRPMList
   # Add the student user
   AddStudent
# End of introductory training installation
else
   ################################################################################
   # Do this stuff when we are NOT in a classroom environment.                    #
   ################################################################################
   Msg="Performing tasks for all non-classroom hosts."
   PrintMsg

   ################################################################################
   # install some administrative tools.                                           #
   ################################################################################
   Msg="Installing some useful administration tools for all environments except the training hosts."
   RPMlist="logwatch powertop ntop atop htop iptraf-ng iotop iftop sysstat rpmorphan lshw hddtemp lm_sensors clamav chkrootkit apcupsd"
   PrintMsg
   InstallRPMList

   # Add the highest level of detail to logwatch.conf if it does not already exist
   cd /etc/logwatch/conf/
   if ! grep "Detail = 10" logwatch.conf > /dev/null
   then
      Msg="Set higher level of detail for logwatch."
      PrintMsg
      # Back up the current logwatch.conf
      cp logwatch.conf logwatch.conf.bak
      echo "Detail = 10" >> logwatch.conf
   fi
   if [ $student = 1 ]
   then
      # Add the student user
      AddStudent
   fi
   # Set up MOTD scripts
   Msg="Setting up MOTD scripts."
   PrintMsg
   cd /etc
   # Save the old MOTD if the backup of the original does not exist
   if [ ! -e motd.orig ]
   then
      cp motd motd.orig
   fi
   # If not there already, Add link to create_motd to cron.daily
   cd /etc/cron.daily
   if [ ! -e create_motd ]
   then
      ln -s /usr/local/bin/create_motd
   fi
   # Create the MOTD. The files were installed by the RPM 
   Msg="Create the initial MOTD."
   PrintMsg
   # create the MOTD for the first time
   /usr/local/bin/createMOTDLinux > /etc/motd

   # Chandge  sshd_config to add the LogBanner file
   Msg="Setting up the logbanner in sshd_config."
   PrintMsg

   # If the LogBanner line does not exist, we append it
   if ! grep LogBanner /etc/ssh/sshd_config > /dev/null
   then
      # back up the original sshd_config
      cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
      # Modify the sshd configuration
      echo "Banner /etc/LogBanner" >> /etc/ssh/sshd_config
      # restart sshd
      if [ $NAME = "Fedora" ]
      then
         systemctl restart sshd.service
      elif [ $NAME = "CentOS" ]
      then
         service sshd restart
      else
         msg="Unsupported operating system: $NAME"
         PrintMsg
      fi
   fi

   ################################################################################
   # If this is Fedora 19 and CentOS 7 and above, we install iptables-services    #
   # which installs the systemd start configuration files for IPTables. They were #
   # split out in Fedora 19 because IPTables is no longer the default firewall.   #
   # Note that CentOS 6.5 still uses IPTables and has not migrated to firewalld.  #
   ################################################################################
   if ( [ $NAME = "Fedora" ] && [ $RELEASE -ge 19 ] ) || ( [ $NAME = "CentOS" ] && [ $RELEASE -ge 7 ]  )
   then
      RPMname="iptables-services"
      if ! RPMisInstalled
      then
         Msg="Install the $RPMname RPM."
         PrintMsg
         yum -y install $RPMname
      fi
      # And we might want to revert to IPTables instead of using firewalld
      if [ $IPTablesRevert = 1 ]
      then
         RevertIPTables
      fi
   fi

   ################################################################################
   # Ensure NTPD is installed and started using the default servers               #
   ################################################################################
   ################################################################################
   # There is currently (at least F17  to 20) a bug in startup that prevents NTPD #
   # from starting automatically at startup. Manual start works. This problem     #
   # Seems to be corrected in Fedora 19.                                          #
   ################################################################################
   ################################################################################
   Msg="Installing NTP."
   PrintMsg
   # If NTP not installed, do it
   RPMlist="ntp ntpdate"
   InstallRPMList
   
   # Now start the NTPD service. 
   if [ $NAME = "Fedora" ]
   then
      # This is for Fedora Using systemctl commands
      Msg="Starting NTP Service - Fedora"
      PrintMsg
      systemctl enable ntpd.service
      # Now restart the ntp service
      systemctl restart ntpd.service
   elif [ $NAME = "CentOS" ]
   then
      # This is for CentOS Using system and chkconfig commands
      Msg="Starting NTP Service - CentOS"
      PrintMsg
      chkconfig ntpd on
      # Now restart the ntp service
      service ntpd restart
   else
      Msg="Invalid operating system $NAME for NTPD startup. "
      PrintMsg
   fi
# End of non-classroom installation
fi


################################################################################
# Set grub.conf to remove "rhgb" from kernel config line, set menu timeout to  #
# 10 seconds and comment out "hiddenmenu". This makes it easier to interrupt   #
# the boot process and make on-the-fly changes to it.                          #
################################################################################
Msg="Modify grub configuration file."
PrintMsg
# Do we have grub or grub2?
if [ -d /boot/grub2 ]
then
   # We have GRUB2
   # Note that "hiddenmenu" is not currently used in GRUB2. Keeping in case it comes back.
   sed -i -e "s/ rhgb / /g" -e "s/^hiddenmenu/# hiddenmenu/" -e "s/timeout=[0-9]$/timeout=10/" /boot/grub2/grub.cfg
else
   # Using GRUB 1
   sed -i -e "s/ rhgb / /g" -e "s/^hiddenmenu/# hiddenmenu/" -e "s/timeout=[0-9]$/timeout=10/" /boot/grub/grub.conf
fi


################################################################################
# Install various common desktops including KDE Gnome, Xfce, and others. But   #
# ONLY by individual options.                                                  #
################################################################################
################################################################################
# Install Cinnamon Desktop on Fedora 18 and above.                             #
################################################################################
if [ $NAME = "Fedora" ] && [ $cinnamon = 1 ] 
then 
   if [ $RELEASE -ge 18 ]
   then
      # Is it already installed?
      GroupName="Cinnamon Desktop"
      if ! GroupisInstalled 
      then
         # Install KDE for Fedora 18 and above
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      else
         Msg="$GroupName is already installed."
         PrintMsg
      fi
   else
      Msg="$GroupName is only supported on Fedora 18 and over."
      PrintMsg
   fi
fi # End install Cinnamon Desktop


################################################################################
# Install GNOME Desktop.                                                       #
################################################################################
if [ $gnome = 1 ] 
then
   RPMname="gnome-session"
   if [ $NAME = "Fedora" ] && ! RPMisInstalled 
   # Install Gnome for Fedora 18 and above 
   then
      # GNOME is not installed so we will install it
      if [ $RELEASE -ge 18 ]
      then
         # Install GNOME for Fedora 18+
         # Set the group name to be installed
         GroupName="GNOME Desktop"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      else
         # Install GNOME for Fedora 16 or 17
         GroupName="GNOME Desktop Environment"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      fi
   elif [ $NAME = "CentOS" ] && ! RPMisInstalled
   then
         GroupName="Desktop"
         Msg="Installing $GroupName -- GNOME Desktop"
         PrintMsg
         yum -y groupinstall "$GroupName"
   fi 
fi # End install GNOME Desktop

################################################################################
# Install KDE                                                                  #
################################################################################
if [ $kde = 1 ]
then
   ################################################################################
   # Do this differently for Fedora and Centos.                                   #
   ################################################################################
   # RPM of a base component for All fedora versions
   # Which version of Fedora? The group name changes with F18.
   if [ $NAME = "Fedora" ] && [ $RELEASE -ge 18 ]  
   then
      RPMname="kde-baseapps"
      # Install KDE for Fedora 18 and above
      if ! rpm -q $RPMname > /dev/null
      then
         GroupName="KDE Plasma Workspaces"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      fi
   elif [ $NAME = "Fedora" ] && [ $RELEASE -lt 18 ]
   then
      # Install KDE for Fedora 17 and below
      if ! rpm -q $RPMname > /dev/null
      then
         GroupName="KDE software compilation"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      fi
   elif [ $NAME = "CentOS" ]
   then
      RPMname="kde-base"
      # Install KDE for CentOS
      if ! rpm -q $RPMname > /dev/null
      then
         GroupName="KDE Desktop"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      fi
   fi
fi # End of KDE install option

################################################################################
# Install LXDE Desktop.                                                        #
################################################################################
if [ $NAME = "Fedora" ] && [ $lxde = 1 ] 
then
   # Install LXDE for Fedora 18 and above 
   # Is it already installed?
   RPMname="lxde-common"
   if ! RPMisInstalled 
   then
      # It is not installed so we will install it
      if [ $RELEASE -ge 18 ]
      then
         # Install LXDE for Fedora 18+
         # Set the group name to be installed
         GroupName="LXDE Desktop"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      else
         # Install LXDE for Fedora 16 or 17
         GroupName="LXDE"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      fi
   fi 
fi # End install LXDE Desktop

################################################################################
# Install MATE Desktop on Fedora 18 and above.                                 #
################################################################################
if [ $NAME = "Fedora" ] && [ $mate = 1 ] 
then
   GroupName="MATE Desktop"
   RPMname="mate-session-manager"
   if [ $RELEASE -ge 18 ]
   then
      # Is it already installed?
      if ! RPMisInstalled 
      then
         # Install MATE for Fedora 18 and above
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      else
         Msg="$GroupName is already installed."
         PrintMsg
      fi
   else
      Msg="$GroupName is only supported on Fedora 18 and over."
      PrintMsg
   fi
fi # End install MATE Desktop

################################################################################
# Install Sugar Desktop                                                        #
################################################################################
if [ $NAME = "Fedora" ] && [ $sugar = 1 ]
then
   # Is it already installed?
   GroupName="Sugar Desktop Environment"
   RPMname="sugar-base"
   if ! RPMisInstalled 
   then
      # Install Sugar for Fedora 18 and above
      Msg="Installing $GroupName"
      PrintMsg
      yum -y groupinstall "$GroupName"
   else
      Msg="$GroupName is already installed."
      PrintMsg
   fi
fi # End install Sugar Desktop

################################################################################
# Install Xfce Desktop.                                                        #
################################################################################
if [ $NAME = "Fedora" ] && [ $xfce = 1 ] 
then
   # Install Xfce for Fedora 18 and above 
   # Is it already installed?
   RPMname="xfce4-session"
   if ! RPMisInstalled 
   then
      # It is not installed so we will install it
      if [ $RELEASE -ge 18 ]
      then
         # Install Xfce for Fedora 18+
         # Set the group name to be installed
         GroupName="Xfce Desktop"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      else
         # Install GNOME for Fedora 16 or 17
         GroupName="Xfce"
         Msg="Installing $GroupName."
         PrintMsg
         yum -y groupinstall "$GroupName"
      fi
   fi 
fi # End install Xfce Desktop

################################################################################
# Stop and disable the firstboot service. This is done here so that any new    #
# display manager will display its login screen as well as show any added      #
# users such as student or dboth. Note that this changed in Fedora 19 to       #
# initial-setup-graphical.service and initial-setup-text.service so this is    #
# no longer effective. At the moment I cannot find the appropriate service.    #
################################################################################
Msg="Disable First Boot service."
PrintMsg
if [ $NAME = "Fedora" ] && [ $RELEASE -lt 19 ] 
then
   systemctl stop firstboot-graphical.service
   systemctl disable firstboot-graphical.service
elif [ $NAME = "CentOS" ]
then
   chkconfig firstboot off
   service firstboot stop
fi


################################################################################
# Install fonts for compatibility and flexibility                              #
################################################################################
if [ $fonts = 1 ]
then
   Msg="Installing common and compatibility fonts."
   PrintMsg
   RPMlist="aajohan-comfortaa-fonts adf-accanthis-2-fonts adf-accanthis-3-fonts adf-accanthis-fonts adf-accanthis-fonts-common adf-gillius-fonts adf-gillius-fonts-common adf-tribun-fonts bitmap-fonts-compat bitstream-vera-fonts-common bitstream-vera-sans-fonts bitstream-vera-sans-mono-fonts bitstream-vera-serif-fonts cf-bonveno-fonts cf-sorts-mill-goudy-fonts chisholm-to-be-continued-fonts ctan-cm-lgc-fonts-common ctan-cm-lgc-roman-fonts ctan-cm-lgc-sans-fonts ctan-cm-lgc-typewriter-fonts darkgarden-fonts ecolier-court-fonts ecolier-court-fonts-common ecolier-court-lignes-fonts extremetuxracer-papercuts-fonts extremetuxracer-papercuts-outline-fonts freecol-imperator-fonts freecol-shadowedblack-fonts ghostscript-fonts gnu-free-fonts-common gnu-free-mono-fonts gnu-free-sans-fonts gnu-free-serif-fonts impallari-lobster-fonts inkboy-fonts liberation-fonts-common liberation-mono-fonts liberation-narrow-fonts liberation-sans-fonts liberation-serif-fonts libreoffice-opensymbol-fonts linux-libertine-fonts oldstandard-sfd-fonts scholarsfonts-cardo-fonts sil-abyssinica-fonts silkscreen-expanded-fonts silkscreen-fonts silkscreen-fonts-common sj-fonts-common sj-stevehand-fonts stix-fonts terminus-fonts terminus-fonts-console thibault-essays1743-fonts thibault-fonts-common thibault-isabella-fonts tlomt-junction-fonts tulrich-tuffy-fonts typemade-josefinsansstd-light-fonts ubuntu-title-fonts un-core-dotum-fonts un-core-fonts-common urw-fonts vlgothic-fonts vlgothic-fonts-common vlgothic-p-fonts vollkorn-fonts woodardworks-laconic-fonts woodardworks-laconic-shadow-fonts wqy-zenhei-fonts xorg-x11-fonts-ISO8859-1-100dpi xorg-x11-fonts-Type1"
   InstallRPMList
   # Now update the font cache
   /usr/bin/fc-cache
fi

################################################################################
# Install applications software.                                               #
################################################################################
if [ $applications = 1 ]
then
   Msg="Install some general GUI applications I normally use on a main workstation with a desktop."
   PrintMsg
   # Install Adobe repository
   installAdobeRepo
   RPMlist="tellico gramps gnucash stellarium kstars celestia gkrellm AdobeReader_enu flash-plugin thunderbird firefox xscreensaver switchdesk krusader"
   InstallRPMList
fi # End install applications

################################################################################
# Install LibreOffice software.                                                #
################################################################################
RPMname="libreoffice-writer"
if [ $LibreOffice = 1 ] && ! RPMisInstalled
then
   Msg="Installing LibreOffice."
   PrintMsg
   Group="LibreOffice"
   yum -y groupinstall $Group
elif [ $NAME = "CentOS" ] && [ $LibreOffice = 1 ] && ! RPMisInstalled
then
   Msg="Installing LibreOffice."
   PrintMsg
   Group="Office Suite and Productivity"
   yum -y groupinstall $Group
fi # End install LibreOffice

################################################################################
# Install multimedia applications I normally use on a main workstation         #
################################################################################
if [ $NAME = "Fedora" ] && [ $multimedia = 1 ]
then
   Msg="Install some multimedia applications normally used on a main workstation."
   PrintMsg
   RPMlist="amarok gstreamer-ffmpeg mplayer mplayer-gui kaffeine vlc xine-ui* xine-lib-extras xine-lib-extras-freeworld xine-lib-pulseaudio xine-plugin"
   InstallRPMList
fi # End install multimedia

################################################################################
# Install development software.                                                #
################################################################################
if [ $development = 1 ]
then
   Msg="Install the kernel development packages, gcc (compiler) and rpm-build"
   PrintMsg
   if [ $Arch = 64 ]
   then
      RPMlist="kernel-devel gcc dkms rpm-build"
   else
      RPMlist="kernel-devel kernel-PAE-devel gcc dkms rpm-build"
   fi
   InstallRPMList
fi

################################################################################
# Install SendMail on all systems as we will either use them as email servers  #
# or they will need SendMail configuration to point to a "SmartHost" for email #
# Forwarding from the primary email host for the domain.                       #
################################################################################
RPMname="sendmail"
if ! RPMisInstalled
then
   Msg="Installing basic SendMail."
   PrintMsg
   RPMlist="sendmail sendmail-cf"
   InstallRPMList
fi

################################################################################
# Add my email address to /etc/aliases if it exists, so that all emails to     #
# root go to my email address. This must be done after installing SendMail.    #
################################################################################
if [ -e /etc/aliases ] && ! grep "david@both.org" /etc/aliases && [ $DavidsStuff = 1 ]
then
   Msg="Setting roots email to go to david@both.org in /etc/alaises."
   PrintMsg
   echo "root:           david@both.org" >> /etc/aliases
   newaliases
fi # End adding my email to /etc/aliases

################################################################################
# Install server software. This section installs the servers I commonly use.   #
################################################################################
if [ $server = 1 ]
then
   Msg="Installing server software"
   PrintMsg
   ################################################################################
   # Install BIND Name Services. This works for Fedora and CentOS, but the        #
   # groupinstall does not. Do not start services.                                #
   ################################################################################
   Msg="Install BIND Name Services"
   PrintMsg
   RPMlist="bind bind-chroot bind-utils"
   InstallRPMList
   # Configure network interface configuration file to use localhost for caching name server
   # and using Google DNS for secondary
   Msg="Setting up caching name server"
   PrintMsg
   cd /etc/sysconfig/network-scripts
   # Determine the active (primary) NIC. This assumes that the primary NIC is the only
   # one configured during installation and that it has 'ONBOOT=yes' or 'ONBOOT="yes"'.
   NIC=`egrep 'ONBOOT=yes|ONBOOT="yes"' ifcfg* | grep -v ifcfg-lo | awk -F : '{print $1}'`

   # Add local and Google public DNS to NIC config. DHCP DNS entry
   # overrides the DNS entries in the NIC config.
   # First Delete all existing DNS entries and then add new ones
   cat $NIC | grep -v DNS > /tmp/$NIC
   cp /tmp/$NIC .
   # Add the localhost as DNS1
   echo "DNS1=127.0.0.1" >> $NIC
   # Add Google as DNS2
   echo "DNS2=8.8.8.8" >> $NIC
   cd
   
   ################################################################################
   # Install SASL for security  and IMAP to manage IMAP and POP email services.   #
   ################################################################################
   RPMname="uw-imap"
   if ! RPMisInstalled
   then
      Msg="Installing IMAP and SASL."
      PrintMsg
      RPMlist="uw-imap cyrus-sasl xinetd"
      InstallRPMList
   fi
   
   ################################################################################
   # Install MySQL for Fedora 18 and below and CentOS 6.x and below. Install      #
   # MariaDB for Fedora 19 and and CentOS 7 and above.                            #
   ################################################################################
   if ( [ $NAME = "Fedora" ] && [ $RELEASE -lt 19 ] ) || ( [ $NAME = "CentOS" ] && [ $RELEASE -lt 7 ]  )
   then
      # Install MySQL in Fedora versions 18 and below
      RPMname="mysql"
      if ! RPMisInstalled
      then
         Msg="Installing MySQL Server."
         PrintMsg
         yum -y groupinstall "MySQL Database"
      fi
   elif ( [ $NAME = "Fedora" ] && [ $RELEASE -ge 19 ] ) || ( [ $NAME = "CentOS" ] && [ $RELEASE -ge 7 ]  )
   then
      # Install MariaDB in Fedora versions 19 and CenntOS 7 and above
      RPMname="mariadb"
      if ! RPMisInstalled
      then
         Msg="Installing MariaDB Server."
         PrintMsg
         yum -y install mariadb mariadb-server
      fi
   else
      Msg="ERROR: Invalid Operating system distribution and release for MySQL or MariaDB."
      PrintMsg
   fi
   
   ################################################################################
   # Install Apache Web Server                                                    #
   ################################################################################
   RPMname="httpd"
   if ! RPMisInstalled
   then
      Msg="Installing Apache Web Server"
      PrintMsg
      yum -y groupinstall "Web Server"
      # Also install a couple other useful packages
      RPMlist="apachetop"
      InstallRPMList
   fi
   
   ################################################################################
   # Install DHCP server                                                          #
   ################################################################################
   RPMname="dhcp"
   if ! RPMisInstalled
   then
      Msg="Installing DHCP Server"
      PrintMsg
      yum -y install dhcp
   fi
fi # End of Server install option


################################################################################
# Do some stuff for my own hosts that needs to be done at the end, such as     #
# after NTP is installed.                                                      #
################################################################################
if [ $DavidsStuff = 1 ]
then
   ################################################################################
   # Remove Evolution except for the database which is used by other applications.#
   ################################################################################
   RPMname="evolution"
   if [ $NAME = "Fedora" ] && RPMisInstalled
   then
      msg="Removing Evolution."
      PrintMsg
      yum -y remove evolution evolution-ews evolution-help
   fi
   ################################################################################
   # Add the NTP server line for my server  by IP address after the "Please       #
   # consider joining" line in /etc/ntp.conf                                      #
   ################################################################################
   Msg="Adding 192.168.0.53 to NTP configuration."
   PrintMsg
   sed -i -e "s/# Please consider joining.*/&\nserver 192.168.0.53 burst iburst prefer/" /etc/ntp.conf
fi

################################################################################
# Do some other stuff that needs to be done at the end.                        #
################################################################################
# If RootKit Hunter is installed, and this is not any type of training environment,
# intall RootKit Hunter and run the database initialization commands.
RPMname="rkhunter"
if [ $TrainingAdvanced = 0 ] &&  [ $TrainingIntro = 0 ] && ! RPMisInstalled
then
   # Install RootKit Hunter
   yum -y install $RPMname
   # Run the database initialization command
   msg="Running database initialization for RootKit Hunter."
   PrintMsg
   # Update the sig files
   rkhunter --update
   # Set the properties database
   rkhunter --propupd
   # Run it for the first time
   rkhunter -c --sk
fi


if [ $DavidsStuff = 1 ]
then
   ################################################################################
   # Print an informational message about configuring crontab for root.           #
   ################################################################################
   echo "################################################################################"
   echo "# A new root crontab has been installed. Edit it and make approriate changes   #"
   echo "# for this host.                                                               #"
   echo "################################################################################"
fi

if [ $reboot = 1 ]
then
   reboot
else
   echo "################################################################################"
   echo "# Please reboot your computer for some of the changes to take effect.          #"
   echo "################################################################################"
fi

exit


################################################################################
################################################################################
# End of program                                                               #
################################################################################
################################################################################
