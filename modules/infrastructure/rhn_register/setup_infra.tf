resource "null_resource" "setup_infra" {
count = "${var.infra_count}"
  connection {
    type     = "ssh"
    user     = "root"
    host = "${element(var.infra_ip_address, count.index)}"
    private_key = "${file(var.infra_private_ssh_key)}"
  }
  provisioner "file" {
    source      = "${path.cwd}/scripts"
    destination = "/tmp"
   
  }


    provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/scripts/*",
      "/tmp/scripts/rhn_register.sh ${var.path_to_ansible_rpms_at_media_server} ${var.path_to_ose_rpms_at_media_server}",
      ]
  
    }

}
