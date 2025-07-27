resource "aws_instance" "backend" {
  count                       = length(var.private_subnet_id)
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = element(var.private_subnet_id, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  tags = {
    Name = "backend-${count.index + 1}"
  }

  # Copy Flask app
  provisioner "file" {
    source      = "${path.module}/app.py"
    destination = "/home/ec2-user/app.py"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.private_ip
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }

  # Install Flask and run app
  provisioner "remote-exec" {
inline = [
  "sudo yum install -y python3 -q",                        
  "command -v pip3 >/dev/null || sudo yum install -y python3-pip", 
  "pip3 install --quiet flask",                           

  "sudo mkdir -p /opt/flask-app",
  "sudo cp /home/ec2-user/app.py /opt/flask-app/app.py",
  "sudo chown ec2-user:ec2-user /opt/flask-app/app.py",

  "sudo tee /etc/systemd/system/flask.service > /dev/null <<EOF\n[Unit]\nDescription=Kerolos Flask App\nAfter=network.target\n\n[Service]\nExecStart=/usr/bin/python3 /opt/flask-app/app.py\nRestart=always\nUser=ec2-user\n\n[Install]\nWantedBy=multi-user.target\nEOF",

  "sudo systemctl daemon-reload",       
  "sudo systemctl enable flask",         # تشغيلها الآن
]


    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.private_ip
      bastion_host        = var.bastion_host
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
