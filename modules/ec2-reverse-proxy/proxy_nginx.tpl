server {
    listen 80;
    location / {
        proxy_pass http://${backend_target};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
