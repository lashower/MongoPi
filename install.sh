eColor()
{
	if [ -z "$2" ]; then echo -e "\e[1;32m${1}\e[0m";
	else echo -e "\e[1;${1}m${2}\e[0m";
	fi
}
eColor "As always make sure you have updated your R-Pi"

sudo apt-get update
sudo apt-get upgrade

eColor "Creating temporary installation directory"
cd ~
mkdir -p mongodb_install
cd mongodb_install

eColor "Downloading binaries."
version=$(cat /etc/os-release | grep "VERSION=" | awk ' { print $2 } ' | sed 's/[()"]//g')
if [ "$version" == "stretch" ]; then
	eColor "  Downloading stretch version of MongoDB"
	wget https://andyfelong.com/downloads/mongodb_stretch_3_0_14_core.zip https://andyfelong.com/downloads/mongodb_stretch_3_0_14_tools.zip
	unzip mongodb_stretch_3_0_14_core.zip
	unzip mongodb_stretch_3_0_14_tools.zip
	# rm -fr __MACOSX mongodb_stretch_3_0_14_core.zip mongodb_stretch_3_0_14_tools.zip
else
	eColor "  Downloading jessie version of MongoDB"
	wget https://andyfelong.com/downloads/core_mongodb_3_0_14.tar.gz https://andyfelong.com/downloads/tools_mongodb_3_0_14.tar.gz
	mkdir core
	mkdir tools
	cd core
	tar -xzf ../core_mongodb_3_0_14.tar.gz
	cd ../tools
	tar -xzf ../tools_mongodb_3_0_14.tar.gz
	cd ..
	# rm -fr core_mongodb_3_0_14.tar.gz tools_mongodb_3_0_14.tar.gz
fi

user=$(grep mongodb /etc/passwd)
if [ -z "$user" ];then 
	eColor "Creating mongodb user"
	sudo adduser --ingroup nogroup --shell /etc/false --disabled-password --gecos "" --no-create-home mongodb
else
	eColor "mongodb user found"
fi

files=$(ls /usr/bin/mongo* 2>/dev/null)
if [ -z "$files" ]; then
	eColor "Creating a backup of original mongo files"
	mkdir -p backup
	cd backup
	cp -R /usr/bin/mongo* .
	cd ..
fi

eColor "Setting file permissions."
sudo chown root:root core/mongo* tools/mongo*
sudo chmod 755 core/mongo* tools/mongo*
sudo strip core/mongo* tools/mongo*
instances=$(ps -u mongodb | grep mongo)
if [ ! -z "$instances" ];then 
	eColor "Stopping mongodb service."
	sudo service mongodb stop
fi
sudo cp -p core/mongo* /usr/bin
sudo cp -p tools/mongo* /usr/bin

sudo mkdir -p /var/log/mongodb;
sudo chown mongodb:mongodb /var/log/mongodb;
sudo mkdir -p /var/lib/mongodb

sudo chown mongodb:mongodb /var/lib/mongodb
sudo chmod 775 /var/lib/mongodb

if [ ! -f "/etc/mongodb.conf" ]; then
	eColor "Creating /etc/mongodb.conf"
	echo '# /etc/mongodb.conf' | sudo tee -a mongodb.conf > /dev/null
	echo '# minimal config file (old style)' | sudo tee -a mongodb.conf > /dev/null
	echo '# Run mongod --help to see a list of options' | sudo tee -a mongodb.conf > /dev/null
	echo '' | sudo tee -a mongodb.conf > /dev/null
	echo 'bind_ip = 127.0.0.1' | sudo tee -a mongodb.conf > /dev/null
	echo 'quiet = true' | sudo tee -a mongodb.conf > /dev/null
	echo 'dbpath = /var/lib/mongodb' | sudo tee -a mongodb.conf > /dev/null
	echo 'logpath = /var/log/mongodb/mongod.log' | sudo tee -a mongodb.conf > /dev/null
	echo 'logappend = true' | sudo tee -a mongodb.conf > /dev/null
	echo 'storageEngine = mmapv1' | sudo tee -a mongodb.conf > /dev/null	
else
	eColor "/etc/mongodb.conf exists."
fi

if [ ! -f "/lib/systemd/system/mongodb.service" ]; then
	eColor "Creating MongoDB service"
	cd /lib/systemd/system
	echo '[Unit]' | sudo tee -a mongodb.service > /dev/null
	echo 'Description=High-performance, schema-free document-oriented database' | sudo tee -a mongodb.service > /dev/null
	echo 'After=network.target' | sudo tee -a mongodb.service > /dev/null
	echo '' | sudo tee -a mongodb.service > /dev/null
	echo '[Service]' | sudo tee -a mongodb.service > /dev/null
	echo 'User=mongodb' | sudo tee -a mongodb.service > /dev/null
	echo 'ExecStart=/usr/bin/mongod --quiet --config /etc/mongodb.conf' | sudo tee -a mongodb.service > /dev/null
	echo '' | sudo tee -a mongodb.service > /dev/null
	echo '[Install]' | sudo tee -a mongodb.service > /dev/null
	echo 'WantedBy=multi-user.target' | sudo tee -a mongodb.service > /dev/null	
else
	eColor "MongoDB service already defined."
fi

eColor "Starting MongoDB"

sudo service mongodb start;

echo -n "Completed install. Do you want to bring down MongoDB? [y/n]"
read answer

if [ "$answer" != "${answer#[Yy]}" ] ;then
	eColor "Stopping MongoDB.";
	sudo service mongodb stop;
fi
cd ~
rm -fr mongodb_install
