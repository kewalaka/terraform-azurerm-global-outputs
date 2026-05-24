locals {
  # Flatten reads into a map of "pk/rk" => { pk, rk, keys } for iteration
  read_entries = {
    for entry in flatten([
      for pk, rk_map in var.reads : [
        for rk, keys in rk_map : {
          id   = "${pk}/${rk}"
          pk   = pk
          rk   = rk
          keys = keys
        }
      ]
    ]) : entry.id => entry
  }

  # Decode each entity once so output shaping can stay type-consistent.
  read_outputs = {
    for id, entity in data.azurerm_storage_table_entity.read :
    id => try(jsondecode(entity.entity.outputs), {})
  }
}
