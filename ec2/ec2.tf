provider "aws" {
  region = var.region
}
data "aws_ami" "my_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-*.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"]
}
resource "aws_vpc" "my_vpc" {
  cidr_block = var.cidr-vpc

  tags = {
    Name = "my-vpc"
  }

}

resource "aws_subnet" "my-subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.cidr-subnet
  availability_zone       = var.azs
  map_public_ip_on_launch = true

  tags = {
    Name = "my-subnet"
  }
}

resource "aws_security_group" "my-sg" {
  vpc_id = aws_vpc.my_vpc.id
  name   = "SG-1"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "my-sg"
  }
}

resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my-igw"
  }
}

resource "aws_route_table" "my-rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }
  tags = {
    Name = "my-rt"
  }
}

resource "aws_route_table_association" "my-rta" {
  subnet_id      = aws_subnet.my-subnet.id
  route_table_id = aws_route_table.my-rt.id
}

resource "aws_instance" "my-instance" {
  count                  = var.instance-count
  ami                    = data.aws_ami.my_ami.id
  key_name               = var.key
  subnet_id              = aws_subnet.my-subnet.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]
  instance_type          = var.itype

  tags = {
    Name = "${var.iname}-${count.index + 1}"
  }

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }
}
