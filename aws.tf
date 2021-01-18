variable "subnet_id" {
  type        = string
  description = "The subnet id"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_security_group" "allow_80" {
  name        = "allow_80_task"
  description = "Allow 80_task inbound traffic"
  vpc_id      = "vpc-02cb160e3bda472bc"

  ingress {
    description = "Allow 80 from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.120.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_80"
  }
}



resource "aws_instance" "awsec2" {
  ami           = "ami-0885b1f6bd170450c"
  instance_type = "t2.micro"
  subnet_id = var.subnet_id
  vpc_security_group_ids              = [
        aws_security_group.allow_80.id
    ]
  tags = {
    Name = "coda-christopher-assessment"
  }
}



resource "aws_s3_bucket" "bucket" {
  bucket = "cg-christopher-assessment-bucket"
  acl = "private"  

  lifecycle_rule {
    enabled = true

    transition {
      days = 30
      storage_class = "GLACIER"
    }
  }
}
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = ["subnet-0e6277d5a74877d79", "subnet-072c46024bacfd71e"]

  tags = {
    Name = "private"
  }
}

resource "aws_db_subnet_group" "assessment-private" {
  name       = "cg-tf-assessment"
  subnet_ids = ["subnet-0e6277d5a74877d79", "subnet-072c46024bacfd71e"]

  tags = {
    Name = "private"
  }
}


resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "mydb"
  username             = "admin"
  password             = "admin123"
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name= "cg-tf-assessment"
  tags = {
    Name = "cg-tf-assesment-db"
  }
}