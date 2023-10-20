# terraform-studio


## Destroying the infrastructure

To destroy the infrastructure, run the following command:

```bash
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan
```