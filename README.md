# PowerTool

<h2>Description</h2>
This utility allows for performing various actions on a remote computer in a Windows Active Directory domain environment. The "Interface" file is the main entry point. It will call additional modules in the "Modules" folder to perform each action.

<h2>Background</h2>
I began this project in my free time at work to teach myself Powershell. I am now working on creating a new version of my original tool that will work with any domain. I will also be continuing to add new features.
Features I plan to add in the future include:
<ul>
<li>Mapping and data analysis of all computers on the network</li>
<li>Wake on lan</li>
<li>Block users from certain computers</li>
</ul>

<h2>Installation</h2>
<ol>
<li>Download the files and put them in a directory of your choice.</li>
<li>Open "Configuration->DomainName" and replace the text with your fully qualified domain name.</li>
<li>Open "Configuration->NetworkLayout" and replace the existing entries with ones for your own network.</li>
</ol>

<h2>Use</h2>
<b>Important note:</b> This is intended for use by people with higher privelages than a standard user. Some features require that your domain account has local administrator privelages on the target computer.
<ul>
<li>Option 1: Open the directory in file explorer, right click on the "Interface.ps1" file, and select run with Powershell</li>
<li>Option 2: Open the Powershell prompt, enter "cd" followed by the path to the directory the files are in, enter ".\Interface.ps1"</li>
</ul>

<h2>Cautions</h2>
<ul>
<li>This was only designed for use in a domain environment.</li>
<li>Powershell's execution policy may prevent the script from being run. To fix this, use "Set-ExecutionPolicy" to set it to "Unrestricted" or "Bypass".</li>
<li>This is intended for use by people with higher privelages than a standard user. Some features require that your domain account has local administrator privelages on the target computer.</li>
<li>Do not misuse this tool.</li>
</ul>

<h2>Modules</h2>
<ul>
<li>Restart - restart the specified computer</li>
<li>Shutdown - shutdown the specified computer</li>
<li>Logoff - logoff the current user on the specified computer</li>
<li>Send message - display a message on the specified computer</li>
<li>Rename - rename the specified computer</li>
<li>Lock - locks the specified computer</li>
<li>Delete System32 - this will actually files in the system32 folder on the specified computer! It was meant primarily as a proof of concept for the spearfish module. Be careful with this.</li>
<li>Who are you - opens a new powershell window to view data about the specified computer</li>
<li>Start network scan - opens a new powershell window that creates a list of hosts and mac addressed on the specified subnet.</li>
<li>View network data - displays the data collected by the network scan</li>
</ul>