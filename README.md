# PowerTool
<h2>Description</h2>
This utility allows for performing various actions on a remote computer in a Windows Active Directory domain environment. The "Interface" file is the main entry point. It will call additional modules in the "Modules" folder to perform each action.
<h2>Background</h2>
I began this project in my free time at work to teach myself Powershell. I have a lot of cool modules, and am working on removing information specific to my workplace in order to make them usable on any domain. The created date in most files is when I created the original version at work.
<h2>Installation</h2>
<ol>
<li>Download the files and put them in a directory of your choice</li>
<li>Open "Configuration->DomainName" and replace the text with your fully qualified domain name</li>
</ol>
<h2>Use</h2>
<ul>
<li>Option 1: Open the directory in file explorer, right click on the "Interface.ps1" file, and select run with Powershell</li>
<li>Option 2: Open the Powershell prompt, enter "cd" followed by the path to the directory the files are in, enter ".\Interface.ps1"</li>
</ul>
<h2>Cautions</h2>
<ul>
<li>I have only tested this with computers in a Windows Active Directory domain. I do not know what the results of using it on a computer that is not part of a domain would be.</li>
<li>Powershell's execution policy may prevent the script from being run. To fix this, use "Set-ExecutionPolicy" to set it to "Unrestricted" or "Bypass".</li>
<li>If you get an error about permission denied, you will have to follow usage option 2, but open the Powershell prompt with the "Run as Administrator" option.</li>
</ul>