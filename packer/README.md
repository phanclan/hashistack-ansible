# Packer information

Create the `variables.json` file. Customize as needed.

```json
{
  "myResourceGroup": "pphan-workshop",
  "myPackerImage": "hashistack-{{isotime \"2006-01-02\"}}",
  "vm_size": "Standard_D2_v4",
  "location": "West US 2",
  "image_sku": "18.04-LTS"
}
```

myResourceGroup - where image should be built
myPackerImage - name of packer image
vm_size - instance type
location - location/region
image_sku - os image to use

Command I use to build Ubuntu 18 in Azure with Hashi products.

```shell
packer build -force -var-file variables.json ubuntu18-azure.json
```
