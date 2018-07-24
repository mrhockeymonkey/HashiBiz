provider aws {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

#data aws_s3_bucket logs {
#  bucket = "hashibiz-logs"
#}

resource aws_vpc hashibiz-vpc {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "hashibiz-vpc"
  }
}

resource aws_subnet hashibiz-net1 {
  vpc_id            = "${aws_vpc.hashibiz-vpc.id}"
  availability_zone = "eu-west-2a"
  cidr_block        = "10.0.2.0/24"

  tags {
    Name = "hashibiz-net1"
  }
}

resource aws_subnet hashibiz-net2 {
  vpc_id            = "${aws_vpc.hashibiz-vpc.id}"
  availability_zone = "eu-west-2b"
  cidr_block        = "10.0.3.0/24"

  tags {
    Name = "hashibiz-net2"
  }
}

resource "aws_internet_gateway" "hashibiz-igw" {
  vpc_id = "${aws_vpc.hashibiz-vpc.id}"

  tags {
    Name = "hashibiz-igw"
  }
}

resource "aws_route_table" "hashibiz-rt" {
  vpc_id = "${aws_vpc.hashibiz-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"                               # special notation to make subnet public
    gateway_id = "${aws_internet_gateway.hashibiz-igw.id}"
  }

  tags {
    Name = "hashibiz-rt"
  }
}

resource "aws_route_table_association" "hashibiz-rta1" {
  subnet_id      = "${aws_subnet.hashibiz-net1.id}"
  route_table_id = "${aws_route_table.hashibiz-rt.id}"
}

resource "aws_route_table_association" "hashibiz-rta2" {
  subnet_id      = "${aws_subnet.hashibiz-net2.id}"
  route_table_id = "${aws_route_table.hashibiz-rt.id}"
}

resource "aws_security_group" "hashibiz-sg-web" {
  name        = "hashibiz-sg-web"
  description = "Allows inbound web traffic on port 80"
  vpc_id      = "${aws_vpc.hashibiz-vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "hashibiz-sg-web"
  }
}

resource "aws_security_group" "hashibiz-sg-ssh" {
  name        = "hashibiz-sg-ssh"
  description = "Allows inbound ssh traffic on port 22"
  vpc_id      = "${aws_vpc.hashibiz-vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "hashibiz-sg-ssh"
  }
}

# elb is the "classic load balancer"
# alb is the application load balancer
# lb == alb phew
resource "aws_lb" "web" {
  name               = "hashibiz-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.hashibiz-sg-web.id}"]
  subnets            = ["${aws_subnet.hashibiz-net1.id}", "${aws_subnet.hashibiz-net2.id}"]

  access_logs {
    bucket  = "hashibiz-logs"
    prefix  = "web"
    enabled = true
  }

  tags {
    Environment = "production"
  }
}

resource "aws_lb_target_group" "web" {
  name        = "hashibiz-web"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = "${aws_vpc.hashibiz-vpc.id}"
  target_type = "instance"

  health_check {
    interval = 10
  }
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = "${aws_lb.web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.web.arn}"
    type             = "forward"
  }
}

resource "aws_key_pair" "hashibiz-key" {
  key_name   = "hashibiz-key"
  public_key = "${file("../.ssh/id_rsa.pub")}"
}

#resource "aws_launch_template" "hashibiz-ec2-web" {
#  name_prefix            = "hashibiz-ec2-web"
#  image_id               = "ami-b8b45ddf"
#  instance_type          = "t2.micro"
#  vpc_security_group_ids = ["${aws_security_group.hashibiz-sg-web.id}", "${aws_security_group.hashibiz-sg-ssh.id}"]
#  key_name               = "${aws_key_pair.hashibiz-key.id}"
#
#  # IAM ROLE?
#  network_interfaces {
#    associate_public_ip_address = true
#  }
#}

resource "aws_launch_configuration" "hashibiz-lc-web" {
  name_prefix   = "hashibiz-web"
  image_id      = "${var.hashibiz-ami-web}"
  instance_type = "t2.micro"

  #iam_instance_profile = ""
  key_name                    = "${aws_key_pair.hashibiz-key.id}"
  security_groups             = ["${aws_security_group.hashibiz-sg-web.id}"]
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "web" {
  name                 = "hashibiz-web"
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["${aws_subnet.hashibiz-net1.id}", "${aws_subnet.hashibiz-net2.id}"]
  launch_configuration = "${aws_launch_configuration.hashibiz-lc-web.name}"
  default_cooldown     = 20

  #load_balancers < this is only for using elb (classic)
  target_group_arns = ["${aws_lb_target_group.web.arn}"] # < this is for alb (application)

  #launch_template = {
  #  id      = "${aws_launch_template.hashibiz-ec2-web.id}"
  #  version = "$$Latest"                                   # default doesnt pick upsates
  #}
}

# To do 
# enable logs to check lb

