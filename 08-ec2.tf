# ... (Data source for ubuntu AMI remains the same)
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  owners = ["062266257890"] # Canonical owner ID
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

# Add a resource to save the private key locally
# This is sensitive and will be masked in output logs.
resource "local_sensitive_file" "private_key_file" {
  content  = tls_private_key.example.private_key_pem
  filename = var.key_name # Saves as "terraform-generated-key" in your directory
  # Set file permissions to be secure for a private key (read/write for owner only)
  file_permission = "0600" 
}

# Create the EC2 instance
resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro" 
  subnet_id     = aws_subnet.public_subnet[0].id # Requires aws_subnet.public resource
  
  # Associate the key pair with the instance using its name
  key_name = aws_key_pair.generated_key.key_name 

  # Associate the security group created above
  vpc_security_group_ids = [aws_security_group.main_vpc_sg.id] # Requires aws_security_group.main_vpc_sg resource

  tags = {
    Name = "var.main_vpc_ec2"
  }
}