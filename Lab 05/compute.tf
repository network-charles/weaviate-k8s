resource "aws_eks_cluster" "eks" {
  name     = "eks"
  role_arn = aws_iam_role.eks-iam-role.arn

  vpc_config {
    endpoint_public_access = true
    subnet_ids = [
      aws_subnet.my_subnet[0].id,
      aws_subnet.my_subnet[1].id
    ]
    security_group_ids = [aws_security_group.sg.id]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.2.0.0/24"
    ip_family         = "ipv4"
  }

  depends_on = [
    aws_iam_role.eks-iam-role
  ]
}

# Create a launch template for ASG 
resource "aws_launch_template" "lt" {
  image_id               = data.aws_ssm_parameter.amazon_eks_ami.insecure_value
  instance_type          = "t3.medium"
  vpc_security_group_ids = [aws_security_group.sg.id]
  # amazon linux rhel 
  user_data = filebase64("${path.module}/k8s_user_data.sh")
  key_name  = aws_key_pair.key_pair.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "workernodes"
  node_role_arn   = aws_iam_role.worker-nodes-iam-role.arn
  subnet_ids = [
    aws_subnet.my_subnet[0].id
  ]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly-Node,
  ]
}

resource "aws_ebs_volume" "weaviate-data" {
  availability_zone = "eu-west-2a"
  size              = 4
  type = "gp2"

  tags = {
    Name = "weaviate-data"
  }
}

#-------------------------------------------------------------------------------#
#                              DataDog                                          #
#-------------------------------------------------------------------------------#

resource "aws_eks_addon" "datadog" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "datadog_operator"
  addon_version = "v0.1.9-eksbuild.1"
}

#-------------------------------------------------------------------------------#
#               AWS Cluster Storage Interface                                   #
#-------------------------------------------------------------------------------#

resource "aws_eks_addon" "csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.29.1-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_ebs_csi_driver.arn
}
