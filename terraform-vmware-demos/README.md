## How to Import VM

```
$ terraform import vsphere_virtual_machine.vm /DC1/vm/DEV/DEV2
vsphere_virtual_machine.vm: Importing from ID "/DC1/vm/DEV/DEV2"...
vsphere_virtual_machine.vm: Import prepared!
  Prepared vsphere_virtual_machine for import
vsphere_virtual_machine.vm: Refreshing state... [id=4219040f-5842-ba52-b7e4-cd9064c1f36c]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```


## Appendix

- [Infrastructure-As-Code with Terraform, VMware and VMware Cloud on AWS](https://cloud.vmware.com/community/2019/11/19/infrastructure-code-terraform-vmware-vmware-cloud-aws/)