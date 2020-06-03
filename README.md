# PowerTool

<h2>Description</h2>
This utility allows for performing various actions on a remote computer in a Windows Active Directory domain environment.

<h2>Background</h2>
I created my original PowerTool as a way to teach myself PowerShell. I am now redesigning it to work on any domain, as well as continuing to add new features.
Features I plan to add in the future include:
<ul>
<li>Block users from certain computers</li>
</ul>

<h2>Installation</h2>
<ol>
<li>Download the files and put them in a directory of your choice.</li>
<li>Open "Configuration->DomainName" and replace the text with your fully qualified domain name.</li>
<li>Open "Configuration->NetworkLayout" and replace the existing entries with ones for your own network.</li>
</ol>

<h2>Use</h2>
<li>Option 1: Open the directory in file explorer, right click on the "Main.ps1" file, and select run with Powershell</li>
<li>Option 2: Open the Powershell prompt, enter "cd" followed by the path to the directory the files are in, enter ".\Main.ps1"</li>
</ul>

<h2>Cautions</h2>
<ul>
<li>This was only designed for use in a domain environment.</li>
<li>Powershell's execution policy may prevent the script from being run. To fix this, use "Set-ExecutionPolicy" to set it to "Unrestricted" or "Bypass".</li>
<li>This is intended for use by people with higher privileges than a standard user. Some features require that your domain account has local administrator privileges on the target computer.</li>
<li>Do not misuse this tool.</li>
</ul>