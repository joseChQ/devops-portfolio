data "aws_ami" "ubuntu_dl_gpu" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Deep Learning Base OSS Nvidia Driver GPU AMI (Ubuntu 24.04)*"]
  }
}

output "ami_dl_id" {
  value       = data.aws_ami.ubuntu_dl_gpu.id
  description = "deep learning ami id"
}
output "ami_dl_name" {
  value       = data.aws_ami.ubuntu_dl_gpu.name
  description = "deep learning ami name"
}

module "vpc" {
  source = "./modules/vpc"

  name            = "ollama-server-1"
  vpc_cidr        = "10.0.0.0/16"
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  azs             = ["us-east-1a", "us-east-1b"]
}

resource "aws_security_group" "ollama_sg" {
  name        = "ollama-sg"
  description = "Allow SSH and Ollama API"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Name = "Ollama-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_access_ollama" {
  description       = "Give access to ollama"
  cidr_ipv4         = "0.0.0.0/0" # Change this with your IP
  cidr_ipv6         = null
  ip_protocol       = "-1"
  security_group_id = aws_security_group.ollama_sg.id
  from_port         = null
  to_port           = null
}

resource "aws_vpc_security_group_egress_rule" "ollama_outbound_ipv4" {
  security_group_id = aws_security_group.ollama_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = null
  ip_protocol       = "-1"
  to_port           = null
}

resource "aws_vpc_security_group_egress_rule" "ollama_outbound_ipv6" {
  security_group_id = aws_security_group.ollama_sg.id
  cidr_ipv6         = "::/0"
  from_port         = null
  ip_protocol       = "-1"
  to_port           = null
}

resource "aws_instance" "ollama_server" {
  ami           = data.aws_ami.ubuntu_dl_gpu.id
  instance_type = "g6.xlarge"
  subnet_id     = module.vpc.public_subnets[0]
  key_name      = aws_key_pair.generated.key_name

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    tags = {
      Name = "Ollama volume"
    }
    volume_type = "gp3"
    volume_size = 80 # size in GB
  }

  connection {
    user        = "ubuntu"
    private_key = tls_private_key.generated.private_key_pem
    host        = self.public_ip
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 1777 /tmp",
      "sleep 140",
      "curl -fsSL https://ollama.com/install.sh | sh",
      "sudo mkdir -p /etc/systemd/system/ollama.service.d",
      <<-EOF
        sudo tee /etc/systemd/system/ollama.service.d/override.conf << EOL
        [Service]
        Environment="OLLAMA_HOST=0.0.0.0:11434"
        Environment="OPENAI_API_KEY=ollama"
        Environment="OLLAMA_CONTEXT_LENGTH=120000"
        EOL
      EOF
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo systemctl daemon-reload",
      "sudo systemctl enable ollama",
      "sudo systemctl restart ollama.service",
      "ollama pull gpt-oss:20b",
    ]
  }

  vpc_security_group_ids = [aws_security_group.ollama_sg.id]

  tags = {
    Name = "Ollama server"
  }
}

output "ollama_server_ip" {
  value = aws_instance.ollama_server.public_ip
}
