#Key-Pair Creation
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_pair["key_name"]
  public_key = var.key_pair["public_key"]
}

#Master Node
resource "aws_instance" "master" {
  ami                    = var.ami
  instance_type          = var.instance_type
  private_ip             = var.master_private_ip[0]
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = var.subnet
  vpc_security_group_ids = var.sg_id
  tags = {
    Name = var.master_instance_name[0]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = file(var.key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${var.scriptpaths}/common.sh"
    destination = "/tmp/common.sh"
  }

  provisioner "file" {
    source      = "${var.scriptpaths}/master.sh"
    destination = "/tmp/master.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname master1",
      "chmod +x /tmp/common.sh /tmp/master.sh",
      "sudo sh /tmp/common.sh",
      "sudo sh /tmp/master.sh",
      "curl -o /tmp/calico.yaml https://docs.projectcalico.org/manifests/calico.yaml",
      "kubectl apply -f /tmp/calico.yaml",
      "kubectl apply -f https://raw.githubusercontent.com/scriptcamp/kubeadm-scripts/main/manifests/metrics-server.yaml",
      "kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml",
      "kubectl create serviceaccount admin-user --namespace kubernetes-dashboard",
      "kubectl create clusterrolebinding admin-user --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:admin-user",
      "mkdir /home/ubuntu/join-token",
      "touch /home/ubuntu/join-token/join /home/ubuntu/join-token/token",
      "chmod 755 /home/ubuntu/join-token/join /home/ubuntu/join-token/token",
      "kubeadm token create --print-join-command > /home/ubuntu/join-token/join",
      "sleep 15",
      "kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath={.secrets[0].name}) -o go-template={{.data.token}} > /home/ubuntu/join-token/token",
      "cat /home/ubuntu/join-token/token | base64 -d > /home/ubuntu/join-token/token_base64_decode",
    ]
  }

  provisioner "local-exec" {
    command = <<EOT
      scp -rp -o StrictHostKeyChecking=no -i ${var.key_path} ubuntu@${self.public_ip}:/home/ubuntu/.kube/config ${var.k8sconfigpaths}/config
      scp -rp -o StrictHostKeyChecking=no -i ${var.key_path} ubuntu@${self.public_ip}:/home/ubuntu/join-token/join ${var.k8sconfigpaths}/join.sh
      scp -rp -o StrictHostKeyChecking=no -i ${var.key_path} ubuntu@${self.public_ip}:/home/ubuntu/join-token/token_base64_decode ${var.k8sconfigpaths}/token
    EOT
  }
}


#Node1
resource "aws_instance" "node" {
  count = var.node_count
  ami                    = var.ami
  instance_type          = var.instance_type
  private_ip             = var.node_private_ip[count.index]
  key_name               = aws_key_pair.key_pair.key_name
  subnet_id              = var.subnet
  vpc_security_group_ids = var.sg_id
  tags = {
    Name = var.node_instance_name[count.index]
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    password    = ""
    private_key = file(var.key_path)
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "${var.scriptpaths}/common.sh"
    destination = "/tmp/common.sh"
  }

  provisioner "file" {
    source      = "${var.k8sconfigpaths}/join.sh"
    destination = "/tmp/join.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname ${var.node_name[count.index]}",
      "mkdir -p /home/ubuntu/.kube",
      "touch /home/ubuntu/.kube/config",
      "sudo chown ubuntu:ubuntu /home/ubuntu/.kube/config",
      "sudo chmod -R 777 /home/ubuntu/.kube/config"
    ]
  }

  provisioner "file" {
    source      = "${var.k8sconfigpaths}/config"
    destination = "/home/ubuntu/.kube/config"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/common.sh /tmp/join.sh",
      "sudo sh /tmp/common.sh",
      "sudo sh /tmp/join.sh",
      "sleep 20",
      "kubectl label node $(hostname -s) node-role.kubernetes.io/worker=worker-new"
    ]
  }

  depends_on = [
    aws_instance.master
  ]
}