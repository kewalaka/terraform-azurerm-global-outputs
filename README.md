# terraform-azurerm-global-outputs

Shares Terraform outputs between independent deployments using an Azure Storage Table as a lightweight key-value store.

Each module call can write a set of outputs (identified by partition key + row key), and any other call can read them back — useful when stacks can't reference each other directly.

## Prerequisites

An Azure Storage Table must exist before using this module.

```hcl
resource "azurerm_storage_table" "global_outputs" {
  name                 = "globalOutputs"
  storage_account_name = azurerm_storage_account.this.name
}
```

The `storage_table_url` is: `https://<storage_account_name>.table.core.windows.net/<table_name>`

## Usage

### Write outputs

```hcl
module "global_outputs" {
  source  = "kewalaka/global-outputs/azurerm"
  version = "~> 1.0"

  storage_table_url = "https://<account>.table.core.windows.net/globalOutputs"

  writes = {
    partition_key = "alz-platform-connectivity-hub"
    row_key       = "australiaeast"
    outputs = {
      hub_virtual_network_id = module.hub_vnet.resource_id
      firewall_ip_address    = "10.10.0.1"
    }
  }
}
```

### Read outputs

```hcl
module "global_outputs" {
  source  = "kewalaka/global-outputs/azurerm"
  version = "~> 1.0"

  storage_table_url = "https://<account>.table.core.windows.net/globalOutputs"

  reads = {
    "alz-platform-connectivity-hub" = {
      "australiaeast"   = ["hub_virtual_network_id"]
      "newzealandnorth" = ["hub_virtual_network_id"]
    }
  }
}

output "hub_vnet_id" {
  value = module.global_outputs.outputs["alz-platform-connectivity-hub"]["australiaeast"].hub_virtual_network_id
}
```

Pass an empty list for a row key to return all stored outputs for that entity:

```hcl
reads = {
  "alz-platform-connectivity-hub" = {
    "australiaeast" = []
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| `storage_table_url` | Storage Table URL (not the resource ID) | `string` | yes |
| `writes` | Partition key, row key, and map of outputs to write | `object` | no |
| `reads` | `partition_key → row_key → list of output keys` to read | `map(map(list(string)))` | no |

## Outputs

| Name | Description |
|------|-------------|
| `outputs` | Nested map: `outputs[partition_key][row_key][output_key]` |

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.9 |
| azurerm | ~> 4.0 |
