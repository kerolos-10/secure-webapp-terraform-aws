
resource "aws_instance" "proxy" {
  count                       = length(var.public_subnet_id)
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = element(var.public_subnet_id, count.index)
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "proxy-${count.index + 1}"
  }

  # Step 1: Install NGINX
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install nginx1 -y",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }

  # Step 2: Print public IP to file
  provisioner "local-exec" {
    command = "echo public-ip${count.index + 1} ${self.public_ip} >> all-ips.txt"
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

# Step 3: Generate reverse proxy config from template

data "template_file" "nginx_config" {
  template = file("${path.module}/proxy_nginx.tpl")
  vars = {
    backend_target = var.backend_target
  }
}

# Step 4: Upload nginx config and reload nginx

resource "null_resource" "configure_nginx" {
  count = 2

  provisioner "file" {
    content     = data.template_file.nginx_config.rendered
    destination = "/tmp/nginx.conf"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.proxy[count.index].public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/nginx.conf /etc/nginx/conf.d/default.conf",
      "sudo nginx -s reload"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.proxy[count.index].public_ip
    }
  }

  depends_on = [aws_instance.proxy]
}

