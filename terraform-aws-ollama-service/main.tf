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

