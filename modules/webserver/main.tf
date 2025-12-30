# 1. Fetch the latest Amazon Linux 2023 AMI (Requirement 2.1)
data "aws_ami" "latest_amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

# 2. Create a unique Key Pair for every instance (Requirement 2.1)
resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.instance_name}-key-${var.instance_suffix}"
  public_key = file(var.public_key)
}

# 3. The EC2 Instance
resource "aws_instance" "this" {
  ami                         = data.aws_ami.latest_amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = aws_key_pair.ssh_key.key_name

  # Use the rendered script from the root main.tf
  user_data                   = var.user_data
  user_data_replace_on_change = true

  tags = merge(var.common_tags, {
    Name = "${var.env_prefix}-${var.instance_name}"
  })
}