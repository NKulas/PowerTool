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
<li>Download the files and put them in a directory of your choice</li>
<li>Open "Configuration->DomainName" and replace the text with your fully qualified domain name</li>
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
</ul>