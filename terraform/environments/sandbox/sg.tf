# Create a security group for EKS worker nodes
resource "aws_security_group" "eks_node_sg" {
  name        = "eks-node-sg"
  description = "Security group for EKS nodes with LiveKit ports open"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "eks-node-sg"
  }
}

# Allow TURN over UDP (port 3478)
resource "aws_security_group_rule" "turn_udp" {
  type              = "ingress"
  from_port         = 3478
  to_port           = 3478
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.eks_node_sg.id

  description = "Allow TURN traffic over UDP (3478)"
}

# Allow LiveKit signaling API (port 7881) over TCP
resource "aws_security_group_rule" "livekit_api_tcp" {
  type              = "ingress"
  from_port         = 7881
  to_port           = 7881
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.eks_node_sg.id

  description = "Allow LiveKit HTTP signaling/API over TCP (7881)"
}

# Allow media traffic from clients (UDP ports 50000–60000)
resource "aws_security_group_rule" "media_udp_range" {
  type              = "ingress"
  from_port         = 50000
  to_port           = 60000
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.eks_node_sg.id

  description = "Allow WebRTC media traffic over UDP (50000-60000)"
}

# Optional: allow all outbound traffic
resource "aws_security_group_rule" "egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.eks_node_sg.id

  description = "Allow all outbound traffic"
}
