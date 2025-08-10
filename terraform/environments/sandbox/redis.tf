

# ElastiCache Redis - Non-cluster mode with Primary + Read Replica
module "redis" {
  source  = "terraform-aws-modules/elasticache/aws"

  # Replication Group Configuration - NON-CLUSTER MODE
  replication_group_id     = "${var.redis_config.name_prefix}-${var.environment}"
  description              = var.redis_config.description
  create_replication_group = true
  create_cluster          = true 
  cluster_id = "${var.redis_config.name_prefix}-${var.environment}"


  # Engine settings
  engine         = "redis"
  engine_version = var.redis_config.engine_version
  port           = 6379
  node_type      = var.redis_config.node_type

  num_cache_clusters = var.redis_config.num_cache_clusters 
  
  # Parameter group
  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"
  parameters = [
    {
      name  = "latency-tracking"
      value = "yes"
    }
  ]

  subnet_ids = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    # Allow access from EKS VPC CIDR
    ingress_vpc = {
      type        = "ingress"
      description = "Redis access from EKS VPC"
      cidr_ipv4   = module.vpc.vpc_cidr_block
      from_port   = 6379
      to_port     = 6379
      ip_protocol = "tcp"
    }
    
    # Allow all outbound traffic
    egress_all = {
      type        = "egress"
      description = "All outbound traffic"
      cidr_ipv4   = "0.0.0.0/0"
      ip_protocol = "-1"
    }
  }

  # High Availability for EKS workloads
  multi_az_enabled           = true
  automatic_failover_enabled = true


  # Backup and maintenance
  snapshot_retention_limit = var.redis_config.backup.snapshot_retention_limit
  snapshot_window         = var.redis_config.backup.snapshot_window
  maintenance_window      = var.redis_config.backup.maintenance_window
  


  # Tags with EKS integration
  tags = {
    Name        = "${var.redis_config.name_prefix}-redis"
    Environment = "sandbox"
    Terraform   = "true"
  }
}

 