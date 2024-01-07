module "static-website"{
    source = "./static-website"
}

module "functionapp"{
    source = "./functionapp"
    account_storage = module.static-website.account_storage
}
