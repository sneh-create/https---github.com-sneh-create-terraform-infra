module "dev_infra" {
  source         = "./infra"
  instance_count = 2
  environment    = "dev"
}

module "stg_infra" {
  source         = "./infra"
  instance_count = 2
  environment    = "stg"
}

module "prd_infra" {
  source         = "./infra"
  instance_count = 1
  environment    = "prd"
}

output "dev_infra_vmpubip" {
  value = module.dev_infra.vmpubips
}

output "stg_infra_vmpubip" {
  value = module.stg_infra.vmpubips
}



output "prd_infra_vmpubip" {
  value = module.prd_infra.vmpubips
}

