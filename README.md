A simple and ugly script to help automate some of the deployment for Duo with Linux servers.
This is written specifally for and tested only on Ubuntu servers.

Prerequisites:
1. The UNIX application should already be configured in the Duo portal.
2. The server will need internet access (repo updates, API access to Duo, etc)
3. git will need to be installed first
``` 
sudo apt install git
```

Note: I have only tested with local auth. 



1. Clone the repo 
```
git clone https://github.com/tylerx626/duo-ubuntu
```
2. Make the .sh executable
```
chmod +x duo-ubuntu/duo_setup.sh
```
3. Run the script 
```
duo-ubuntu/./duo_setup.sh
```
4. Enter Duo config info when prompted
5. Fix all the errors and run it again
6. Repeat until it works ;-P


Future updates wish-list:
1. Error-checking
2. SSH key-based auth

