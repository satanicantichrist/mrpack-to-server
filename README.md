# mrpack-to-server
Turns ```.mrpack``` modpack to runnable server. With only mods that are needed on the server.

for now, works only for fabric and neoforge based modpacks
---

# Requirements
jq - for working with json data from modrinth api. ```apt install jq```

# Instalation:
To download run this command
```git clone https://github.com/satanicantichrist/mrpack-to-server.git```

# Usage
To generate server from ```.mrpack``` file, run this command
```server_generator.sh <path to .mrpack file>```

Server will be outputed in to ```server``` folder, where you can run ```start.sh``` script to start the server.

to change the ```start.sh``` script for all future generations, edit the ```default_server_start.sh```
