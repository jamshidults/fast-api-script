# ROll OUT
## Upgrade and Install Odoo Modules

- [ ] Run the script and upgrade `cfed_fls`, install new UI module and access module
- [ ] Set the appropriate access to users - (we need to automate this at the module level instead of manual work)

## Firefox Installation and Print Configuration

- [ ] Check the Firefox version. If it's not 132.0 or greater, download and install the latest Firefox

### Test Print Procedure

- [ ] Open the URL: https://fls_retail_app.ultsglobal.com
- [ ] Use credentials:
  - User: `admin`, Password: `ults@1234`
  - User: `1360`, Password: `1360`
- [ ] Open the new app and test the print
- [ ] In the print popup:
  - Choose the POS printer
  - Choose the Paper with size **80 X 3276**
  - Change the default scale settings to **scale 100**  from **fit to page**
- [ ] Enable Silent Print:
  - In the Firefox address bar, type `about:config`
  - Search for `print.always`
  - Set it to `true`

## Install and Configure Backup Application

- [ ] Open terminal using `Ctrl + Alt + T`
- [ ] wget https://github.com/jamshidults/fast-api-script/archive/refs/heads/main.tar.gz
- [ ] `tar -xzvf main.tar.gz`
- [ ] Navigate to the directory: `cd fast-api-script-main`

#### Install the Fast API Backup Application

- [ ] `chmod +x fast_api.sh`
- [ ] `./fast_api.sh`

#### Reset the Database Every Wednesday

- [ ] `chmod +x db_reset_cron.sh`
- [ ] `./db_reset_cron.sh`





#### Configure the backup URL in the Odoo app : Retails Settings

- [ ] backupURL : http://machine_ip:8000/orders
- [ ] Disable log push scheduled action from odoo technical settings and disable log file on os level crontab also


### To reset and Startover
``` bash
cd fls_backup/
./manage_service.sh stop
sudo systemctl disable fastapi
sudo rm /etc/systemd/system/fastapi.service
cd ..
rm -rf fls_backup/

then download and execute the script
wget https://github.com/jamshidults/fast-api-script/archive/refs/heads/main.tar.gz
```