
resource "null_resource" "create_dns" {
  # Put all the inputs you’ll need later into triggers
  triggers = {
    dns_name         = "api.${var.cluster_id}"
    dns_name_ingress = "*.apps.${var.cluster_id}"
    dns_zone         = var.base_domain
    dns_ip           = var.openshift_api_virtualip
    dns_ip_ingress   = var.openshift_ingress_virtualip
    dns_server       = var.vm_dns_addresses[0]
  }

  # -------- create (apply) --------
  provisioner "local-exec" {
    command = <<-EOF
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook -i ansible/inventory.ini ansible/create_dns.yml \
        --extra-vars "dns_name=${self.triggers.dns_name} \
                      dns_zone=${self.triggers.dns_zone} \
                      dns_ip=${self.triggers.dns_ip} \
                      dns_name_ingress=${self.triggers.dns_name_ingress} \
                      dns_ip_ingress=${self.triggers.dns_ip_ingress} \
                      dns_server=${self.triggers.dns_server}"
    EOF
  }

  # -------- destroy --------
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOF
      ANSIBLE_HOST_KEY_CHECKING=False \
      ansible-playbook -i ansible/inventory.ini ansible/delete_dns.yml \
        --extra-vars "dns_name=${self.triggers.dns_name} \
                      dns_zone=${self.triggers.dns_zone} \
                      dns_name_ingress=${self.triggers.dns_name_ingress} \
                      dns_ip_ingress=${self.triggers.dns_ip_ingress}"
    EOF
  }
}
