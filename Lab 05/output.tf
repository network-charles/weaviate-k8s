output "eks_login" {
  value = "aws eks update-kubeconfig --name ${aws_eks_cluster.eks.id}"
}

output "nodeport_access" {
  value = "${data.aws_instance.instance.public_ip}:NodePort"
}

output "instance_ssh" {
  value = "ssh -i ${aws_key_pair.key_pair.key_name}.pem ec2-user@${data.aws_instance.instance.public_ip}"
}

