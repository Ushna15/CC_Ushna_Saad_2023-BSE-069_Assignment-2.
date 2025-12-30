# 1. Create the VPC
resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# 2. Create the Subnet
resource "aws_subnet" "myapp-subnet-1" {
  vpc_id                  = aws_vpc.myapp-vpc.id
  cidr_block              = var.subnet_cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true # This makes it a "Public" subnet
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

# 3. Create the Internet Gateway (The "Front Door")
resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = {
    Name = "${var.env_prefix}-igw"
  }
}

# 4. Create the Route Table
resource "aws_route_table" "main-rtb" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0" # Traffic heading to the internet...
    gateway_id = aws_internet_gateway.myapp-igw.id # ...goes through the IGW
  }

  tags = {
    Name = "${var.env_prefix}-main-rtb"
  }
}

# 5. Associate Subnet with Route Table
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id      = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.main-rtb.id
}