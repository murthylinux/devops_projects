## Public EC2 Instance

resource "aws_instance" "ec2_pub_inst" {
  ami                    = "ami-0287a05f0ef0e9d9a"
  instance_type          = "t2.micro"
  key_name               = "devops"
  subnet_id              = aws_subnet.vc_pub_sub.id
  vpc_security_group_ids = [aws_security_group.vc_sg.id]
  for_each               = toset(["jen-master", "jen-slave", "ansible"])


  tags = {
    Name = "${each.key}"
  }
}
