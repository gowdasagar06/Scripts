# 7. Write systemd unit files to define and automate service startup and behavior for custom applications.
[Unit]
Description=Application Description
After=network.target

[Service]
Type=simple
ExecStart=/path/to/myapp/executable
WorkingDirectory=/path/to/myapp/directory
Restart=always

[Install]
WantedBy=multi-user.target

#sudo systemctl daemon-reload
#sudo systemctl enable myapp.service
#sudo systemctl start myapp.service
#sudo systemctl status myapp.service
